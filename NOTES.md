Create virtual environment
```bash
python3 -m venv venv
```

Activate virtual environment
```bash
source venv/bin/activate
```

Upgrade pip
```bash
pip install --upgrade pip
```

Install dependencies
```bash
pip install -r requirements.txt
```

Install roles
```bash
ansible-galaxy install -r requirements.yml
```

Initialize role
```bash
ansible-galaxy role init {role_name}
```

Initialize molecule test scenario
```bash
molecule init scenario
```

Check for available versions of some packages
```bash
pip index versions yamllint
```

Run playbook
```bash
ansible-playbook -i inventory/dev/dev.yml --limit frog2 playbook/site.yml --vault-pass-file .vault_pass
```