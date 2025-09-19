#!/usr/bin/env python3
"""
Homelab Container Migration Script
Migrates .env files, configs, and volumes between servers with minimal downtime
"""

import os
import sys
import subprocess
import argparse
import json
import time
from pathlib import Path
from typing import List, Dict, Optional, Tuple
import shlex

# ANSI color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def log(message: str):
    """Print info message"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

def warn(message: str):
    """Print warning message"""
    print(f"{Colors.YELLOW}[WARN]{Colors.NC} {message}")

def error(message: str):
    """Print error message"""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

def success(message: str):
    """Print success message"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

class ContainerMigrator:
    def __init__(self):
        self.source_dir = Path.cwd()
        self.source_config_dir = Path.home() / "config"
        self.target_host = ""
        self.target_user = ""
        self.target_dir = ""
        self.target_config_dir = ""
        self.local_runtime = ""
        self.target_runtime = ""
        self.backup_dir = Path("./volume-backups")
        
    def detect_container_runtime(self, remote: bool = False) -> str:
        """Detect container runtime (docker or podman)"""
        if remote:
            cmd = "command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 && echo docker || (command -v podman >/dev/null 2>&1 && echo podman || echo '')"
            result = self.ssh_command(cmd, check=False)
            return result.stdout.strip() if result.returncode == 0 else ""
        else:
            try:
                subprocess.run(["docker", "info"], capture_output=True, check=True)
                return "docker"
            except (subprocess.CalledProcessError, FileNotFoundError):
                try:
                    subprocess.run(["podman", "info"], capture_output=True, check=True)
                    return "podman"
                except (subprocess.CalledProcessError, FileNotFoundError):
                    return ""
    
    def get_compose_cmd(self, runtime: str) -> str:
        """Get compose command for runtime"""
        if runtime == "docker":
            return "docker compose"
        elif runtime == "podman":
            # Check for podman-compose first
            try:
                subprocess.run(["podman-compose", "--version"], capture_output=True, check=True)
                return "podman-compose"
            except (subprocess.CalledProcessError, FileNotFoundError):
                return "podman compose"
        return ""
    
    def ssh_command(self, command: str, check: bool = True) -> subprocess.CompletedProcess:
        """Execute command on remote host via SSH"""
        ssh_cmd = f"ssh {self.target_user}@{self.target_host} {shlex.quote(command)}"
        return subprocess.run(ssh_cmd, shell=True, capture_output=True, text=True, check=check)
    
    def scp_file(self, source: str, destination: str) -> bool:
        """Copy file to remote host via SCP"""
        scp_cmd = f"scp {source} {self.target_user}@{self.target_host}:{destination}"
        result = subprocess.run(scp_cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0
    
    def rsync_dir(self, source: str, destination: str) -> bool:
        """Sync directory to remote host via rsync"""
        rsync_cmd = f"rsync -avz --progress {source}/ {self.target_user}@{self.target_host}:{destination}/"
        result = subprocess.run(rsync_cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            error(f"rsync failed: {result.stderr}")
        else:
            print(result.stdout)
        return result.returncode == 0
    
    def verify_ssh_connection(self) -> bool:
        """Test SSH connection to target"""
        log(f"Testing SSH connection to {self.target_user}@{self.target_host}...")
        result = self.ssh_command("echo 'SSH connection successful'", check=False)
        if result.returncode == 0:
            success(f"SSH connection to {self.target_user}@{self.target_host} verified")
            return True
        else:
            error(f"Failed to connect to {self.target_user}@{self.target_host}")
            return False
    
    def verify_remote_repo(self) -> bool:
        """Verify remote homelab repository exists"""
        log("Verifying remote homelab repository and container runtime...")
        
        # Expand tilde for target directories
        expand_cmd = f"eval echo '{self.target_dir}'"
        result = self.ssh_command(expand_cmd, check=False)
        if result.returncode == 0:
            self.target_dir = result.stdout.strip()
        
        expand_cmd = f"eval echo '{self.target_config_dir}'"
        result = self.ssh_command(expand_cmd, check=False)
        if result.returncode == 0:
            self.target_config_dir = result.stdout.strip()
        
        # Check if target is a git repo
        check_cmd = f"cd {self.target_dir} && git status"
        result = self.ssh_command(check_cmd, check=False)
        if result.returncode != 0:
            error(f"Target directory {self.target_dir} is not a git repository or doesn't exist")
            error("Please ensure the homelab-containers repo is cloned and checked out on the target server")
            return False
        success(f"Target homelab repository verified at {self.target_dir}")
        
        # Detect target runtime
        self.target_runtime = self.detect_container_runtime(remote=True)
        if not self.target_runtime:
            error("No container runtime (docker/podman) found on target server")
            return False
        success(f"Target container runtime: {self.target_runtime}")
        
        # Create config directory if needed
        mkdir_cmd = f"mkdir -p {self.target_config_dir}"
        result = self.ssh_command(mkdir_cmd, check=False)
        if result.returncode != 0:
            error(f"Cannot create config directory {self.target_config_dir}")
            return False
        success(f"Target config directory {self.target_config_dir} verified/created")
        
        return True
    
    def get_target_details(self, target_host: Optional[str] = None):
        """Get target server configuration"""
        if target_host:
            # Auto mode - use defaults
            self.target_host = target_host
            self.target_user = os.getlogin()
            self.target_dir = "~/git/homelab-containers"
            self.target_config_dir = "~/config"
            log(f"Using provided target: {self.target_host}")
            log(f"Using defaults: user={self.target_user}, homelab={self.target_dir}, config={self.target_config_dir}")
        else:
            # Manual mode - prompt for details
            print("\n=== Migration Target Configuration ===")
            self.target_host = input("Enter target hostname/IP: ")
            self.target_user = input(f"Enter target username [{os.getlogin()}]: ") or os.getlogin()
            self.target_dir = input("Enter target homelab directory [~/git/homelab-containers]: ") or "~/git/homelab-containers"
            self.target_config_dir = input("Enter target config directory [~/config]: ") or "~/config"
        
        # Verify connection and repo
        while True:
            if self.verify_ssh_connection() and self.verify_remote_repo():
                print(f"\nTarget Configuration:")
                print(f"  Host: {self.target_host}")
                print(f"  User: {self.target_user}")
                print(f"  Homelab Dir: {self.target_dir}")
                print(f"  Config Dir: {self.target_config_dir}")
                
                if target_host or input("\nIs this correct? (y/n): ").lower() == 'y':
                    break
            else:
                if not input("\nTry again with different settings? (y/n): ").lower() == 'y':
                    error("Migration aborted")
                    sys.exit(1)
                self.get_target_details()
    
    def find_env_files(self) -> List[Path]:
        """Find all .env files in source directory"""
        return sorted(self.source_dir.glob("*/.env"))
    
    def copy_env_files(self):
        """Copy .env files to existing containers on target"""
        log("Phase 1: Copying .env files to existing containers...")
        
        env_files = self.find_env_files()
        if not env_files:
            warn("No .env files found")
            return
        
        total = len(env_files)
        log(f"Found {total} .env files to process:")
        for f in env_files:
            print(f"  - {f.relative_to(self.source_dir)}")
        
        copied = 0
        skipped = 0
        
        for i, env_file in enumerate(env_files, 1):
            rel_path = env_file.relative_to(self.source_dir)
            container_name = rel_path.parent
            target_path = f"{self.target_dir}/{rel_path}"
            
            log(f"[{i}/{total}] Processing {rel_path}...")
            
            # Check if container exists on target
            check_cmd = f"test -d '{self.target_dir}/{container_name}' && (test -f '{self.target_dir}/{container_name}/docker-compose.yml' || test -f '{self.target_dir}/{container_name}/docker-compose.yaml')"
            result = self.ssh_command(check_cmd, check=False)
            
            if result.returncode != 0:
                warn(f"  Container '{container_name}' not found on target server, skipping .env")
                skipped += 1
                continue
            
            # Check if target .env exists
            check_env_cmd = f"test -f '{target_path}'"
            result = self.ssh_command(check_env_cmd, check=False)
            if result.returncode == 0:
                log(f"  Overwriting existing .env: {target_path}")
            
            # Copy .env file
            if self.scp_file(str(env_file), target_path):
                success(f"  Copied {rel_path}")
                copied += 1
            else:
                error(f"  Failed to copy {rel_path}")
                skipped += 1
        
        log(f"Summary: Copied {copied} .env files, skipped {skipped} out of {total} total")
    
    def find_containers(self) -> List[Path]:
        """Find all container directories with docker-compose files"""
        containers = []
        for d in self.source_dir.iterdir():
            if d.is_dir() and d.name not in ['.git', '.', '..']:
                compose_yml = d / "docker-compose.yml"
                compose_yaml = d / "docker-compose.yaml"
                if compose_yml.exists() or compose_yaml.exists():
                    containers.append(d)
        return sorted(containers)
    
    def backup_named_volumes(self):
        """Backup named volumes for all containers"""
        log("Phase 0: Backing up named volumes...")
        
        self.backup_dir.mkdir(exist_ok=True)
        containers = self.find_containers()
        compose_cmd = self.get_compose_cmd(self.local_runtime)
        
        for container_dir in containers:
            container_name = container_dir.name
            
            # Get running containers
            cmd = f"cd {container_dir} && {compose_cmd} ps -q"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode != 0 or not result.stdout.strip():
                continue
            
            container_ids = result.stdout.strip().split('\n')
            
            for container_id in container_ids:
                # Get volume info
                cmd = f"{self.local_runtime} inspect {container_id} --format='{{{{range .Mounts}}}}{{{{if eq .Type \"volume\"}}}}{{{{.Name}}}}:{{{{.Destination}}}}{{{{\"\\n\"}}}}{{{{end}}}}{{{{end}}}}'"
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
                
                if result.returncode == 0 and result.stdout.strip():
                    for line in result.stdout.strip().split('\n'):
                        if ':' in line:
                            volume_name, volume_path = line.split(':', 1)
                            
                            # Skip cache volumes
                            if any(skip in volume_name.lower() for skip in ['cache', 'tmp', 'temp']):
                                log(f"  Skipping cache/temp volume: {volume_name} (will rebuild on target)")
                                continue
                            
                            # Check volume size
                            size_cmd = f"{self.local_runtime} run --rm -v {volume_name}:{volume_path}:ro alpine:latest du -sh {volume_path}"
                            size_result = subprocess.run(size_cmd, shell=True, capture_output=True, text=True)
                            size = size_result.stdout.split()[0] if size_result.returncode == 0 else "unknown"
                            
                            backup_file = self.backup_dir / f"{container_name}_{volume_name}.tar"
                            log(f"  Backing up volume: {volume_name} (size: {size}) -> {backup_file}")
                            
                            # Create backup
                            backup_cmd = f"{self.local_runtime} run --rm -v {volume_name}:{volume_path}:ro -v {self.backup_dir.absolute()}:/backup alpine:latest tar czf /backup/{backup_file.name} -C {volume_path} ."
                            subprocess.run(backup_cmd, shell=True, capture_output=True)
        
        success(f"Volume backups completed in {self.backup_dir}")
    
    def restore_named_volumes(self):
        """Restore named volumes on target"""
        log("Restoring named volumes on target...")
        
        if not self.backup_dir.exists():
            warn("No volume backups found")
            return
        
        # Copy backups to target
        log("Copying volume backups to target...")
        remote_backup_dir = "~/volume-backups"
        self.ssh_command(f"mkdir -p {remote_backup_dir}")
        self.rsync_dir(str(self.backup_dir), remote_backup_dir)
        
        # Restore each backup
        for backup_file in self.backup_dir.glob("*.tar"):
            filename = backup_file.name
            parts = filename.replace('.tar', '').split('_', 1)
            if len(parts) == 2:
                container_name, volume_name = parts
                log(f"Restoring {volume_name} for {container_name}...")
                
                restore_cmd = f"""
                {self.target_runtime} volume create {volume_name} >/dev/null 2>&1 || true
                {self.target_runtime} run --rm -v {volume_name}:/restore -v {remote_backup_dir}:/backup alpine:latest tar xzf /backup/{filename} -C /restore/
                """
                self.ssh_command(restore_cmd)
        
        success("Volume restoration completed")
    
    def migrate_container_configs(self):
        """Migrate container configurations"""
        log("Phase 2: Migrating container configurations...")
        
        containers = self.find_containers()
        compose_cmd = self.get_compose_cmd(self.local_runtime)
        target_compose_cmd = self.get_compose_cmd(self.target_runtime)
        
        migrated = 0
        skipped = 0
        
        for container_dir in containers:
            container_name = container_dir.name
            source_config = self.source_config_dir / container_name
            target_config = f"{self.target_config_dir}/{container_name}"
            
            # Check if container exists on target
            check_cmd = f"test -d '{self.target_dir}/{container_name}' && (test -f '{self.target_dir}/{container_name}/docker-compose.yml' || test -f '{self.target_dir}/{container_name}/docker-compose.yaml')"
            result = self.ssh_command(check_cmd, check=False)
            
            if result.returncode != 0:
                warn(f"Container '{container_name}' not found on target server, skipping config migration")
                skipped += 1
                continue
            
            # Skip if no local config directory
            if not source_config.exists():
                log(f"No local config directory for {container_name}, skipping")
                skipped += 1
                continue
            
            log(f"Migrating {container_name}...")
            
            # Stop container locally
            log(f"Stopping {container_name} locally...")
            stop_cmd = f"cd {container_dir} && {compose_cmd} down"
            subprocess.run(stop_cmd, shell=True, capture_output=True)
            
            # Copy config directory
            log(f"Copying config for {container_name}...")
            self.ssh_command(f"mkdir -p {self.target_config_dir}")
            self.rsync_dir(str(source_config), target_config)
            
            # Start container on target
            log(f"Starting {container_name} on target...")
            start_cmd = f"cd {self.target_dir}/{container_name} && {target_compose_cmd} up -d"
            result = self.ssh_command(start_cmd, check=False)
            if result.returncode != 0:
                warn(f"Failed to start {container_name} on target")
            else:
                success(f"Migrated {container_name}")
            
            migrated += 1
            time.sleep(2)  # Small delay between containers
        
        log(f"Migrated {migrated} containers, skipped {skipped}")
    
    def verify_proxy_network(self):
        """Verify proxy network exists on target"""
        log("Verifying proxy network on target...")
        
        check_cmd = f"{self.target_runtime} network inspect proxy"
        result = self.ssh_command(check_cmd, check=False)
        
        if result.returncode == 0:
            success("Proxy network exists on target")
        else:
            warn("Proxy network doesn't exist on target")
            if input("Create proxy network on target? (y/n): ").lower() == 'y':
                self.ssh_command(f"{self.target_runtime} network create proxy")
                success("Proxy network created on target")
            else:
                warn(f"You'll need to create the proxy network manually: {self.target_runtime} network create proxy")
    
    def run(self, target_host: Optional[str] = None):
        """Run the migration process"""
        print("=" * 44)
        print("    Homelab Container Migration Script")
        print("=" * 44)
        print()
        
        log(f"Source directory: {self.source_dir}")
        log(f"Source config directory: {self.source_config_dir}")
        
        # Detect local runtime
        self.local_runtime = self.detect_container_runtime()
        if not self.local_runtime:
            error("No container runtime (docker/podman) found locally")
            sys.exit(1)
        log(f"Local container runtime: {self.local_runtime}")
        print()
        
        # Get target details
        self.get_target_details(target_host)
        
        print()
        log("Starting migration process...")
        
        # Verify proxy network
        self.verify_proxy_network()
        
        # Select migration type
        print("\nData Migration Options:")
        print("1. Config only (fastest)")
        print("2. Config + Named volumes backup/restore")
        print()
        
        migration_type = input("Select migration type (1-2): ")
        
        if migration_type == "2":
            self.backup_named_volumes()
        
        # Copy .env files
        self.copy_env_files()
        
        # Migrate configs
        print()
        if input("About to start container migration with downtime. Continue? (y/n): ").lower() == 'y':
            self.migrate_container_configs()
            
            if migration_type == "2":
                self.restore_named_volumes()
        else:
            log("Migration stopped before container migration phase")
            return
        
        print()
        success("Migration completed!")
        print()
        log("Next steps:")
        log("1. Verify all containers are running on the target server")
        log("2. Update DNS/routing to point to the new server")
        log("3. Test all services are working correctly")
        log("4. Clean up old containers on this server when satisfied")

def main():
    parser = argparse.ArgumentParser(description="Migrate homelab containers to another server")
    parser.add_argument("target", nargs="?", help="Target server hostname/IP (optional)")
    args = parser.parse_args()
    
    migrator = ContainerMigrator()
    try:
        migrator.run(args.target)
    except KeyboardInterrupt:
        print("\n\nMigration interrupted by user")
        sys.exit(1)
    except Exception as e:
        error(f"Migration failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()