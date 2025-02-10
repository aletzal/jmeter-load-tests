from enum import Enum

import requests


class RepoType(Enum):
    FILE = 'FILE'
    PYTHON = 'PYTHON'
    CONTAINER = 'CONTAINER'
    GOLANG = 'GOLANG'
    MAVEN = 'MAVEN'


class RepoAccess(Enum):
    PRIVATE = 'PRIVATE'
    PUBLIC = 'PUBLIC'


class KoderaClient(object):
    def __init__(self, url):
        self.access_token = None
        self.url = url

    def sign_in(self, username: str, password: str):
        creds = {
            'usernameOrEmail': username,
            'password': password,
        }
        with requests.Session() as session:
            response = session.post(url=f'{self.url}/api/auth/signin', json=creds)
            response.raise_for_status()
            self.access_token = response.json()['accessToken']

    def create_repo_if_not_exists(self, repo_name: str, repo_type: RepoType, repo_access: RepoAccess = RepoAccess.PUBLIC):
        repos = self.get_repositories()
        if any(repo.get('name') == repo_name for repo in repos):
            return
        payload = {
            'access': repo_access.value,
            'name': repo_name,
            'type': repo_type.value,
        }
        self.post_repositories(payload)

    def delete_all_repositories(self):
        repositories = self.get_repositories()
        for repo in repositories:
            self.delete_repositories(repo.get('id'))

    def get_me(self):
        return self._http_get_request('/api/users/me')

    def get_repositories(self):
        return self._http_get_request('/api/repositories')

    def post_repositories(self, data):
        return self._http_post_request('/api/repositories', json=data)

    def delete_repositories(self, id: int):
        return self._http_delete_request(f'/api/repositories/{id}')

    def post_users_tokens_me(self):
        payload = {
            'expiration': 'MONTH',
            'tokenName': 'month_token'
        }
        return self._http_post_request('/api/users/tokens/me', json=payload)

    def _http_get_request(self, path, **kwargs):
        return self._http_request('GET', path, **kwargs)

    def _http_post_request(self, path, **kwargs):
        return self._http_request('POST', path, **kwargs)

    def _http_delete_request(self, path, **kwargs):
        return self._http_request('DELETE', path, **kwargs)

    def _http_request(self, method, path, **kwargs):
        with requests.Session() as session:
            response = session.request(method=method, url=f'{self.url}{path}', headers=self.__get_bearer_header(),
                                       **kwargs)
            response.raise_for_status()
            return response if method == 'DELETE' else response.json()

    def __get_bearer_header(self):
        return {
            'Authorization': f'Bearer {self.access_token}',
        }
