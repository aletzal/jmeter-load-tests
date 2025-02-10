import os
import subprocess

from dotenv import load_dotenv
from kodera import KoderaClient, RepoType

TEST_REPOS = [
    {'test-repo-file': RepoType.FILE},
    {'test-repo-python': RepoType.PYTHON},
    {'test-repo-container': RepoType.CONTAINER},
    {'test-repo-go': RepoType.GOLANG},
    {'test-repo-maven': RepoType.MAVEN},
]

load_dotenv()

def execute_shell_command(command: str):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        print(f'Command finished successfully!\nOutput: {result.stdout.strip()}')
    else:
        print(f'Command failed {result.returncode}\nError: {result}.')

def main():
    username = os.getenv("USERNAME")
    password = os.getenv("PASSWORD")
    api_url = os.getenv("API_URL")

    kodera = KoderaClient(api_url)
    kodera.sign_in(username, password)

    # clean all existed repos
    kodera.delete_all_repositories()

    # ensure all test repos are created
    for repo in TEST_REPOS:
        repo_name, repo_type = next(iter(repo.items()))
        kodera.create_repo_if_not_exists(repo_name, repo_type)

    execute_shell_command(f'python/upload/upload_to_custom_repo.sh {api_url}/api/python/test-repo-python {username} {password}')

if __name__ == '__main__':
    main()
