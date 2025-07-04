### Prerequisites

#### Make sure to have empty `files`, `logs` directories in the same root for the bash script `install.sh`.

```bash
mkdir -p files logs
sudo chown -R 1000:33 files logs
sudo chmod -R 777 files logs
```

#### Import desired ILIAS branch from [GitHub Repository](https://github.com/ILIAS-eLearning/ILIAS) in directory called `src`.

Example:
```bash
git clone -b release_9 https://github.com/ILIAS-eLearning/ILIAS.git src
```

### To install ILIAS run

```bash
./install.sh <project_name> <web_port> <db_port>
```

