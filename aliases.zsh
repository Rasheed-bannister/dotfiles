alias reload!='. ~/.zshrc && source ~/.zshrc'

alias cls='clear'
alias py='python3.13'
alias pip='pip3'


create_py_project() {
    if [ -z "$1" ]; then
        echo "Please provide a project name"
        return 1
    fi

    # Set variables
    BASE_DIR="$HOME/python_projects"
    PROJECT_DIR="$BASE_DIR/$1"

    # Create base directory if it doesn't exist
    mkdir -p "$BASE_DIR"

    # Check if project already exists
    if [ -d "$PROJECT_DIR" ]; then
        echo "Project directory already exists"
        return 1
    fi

    # Create project directory and navigate to it
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"

    # Initialize uv project
    uv venv
    source .venv/bin/activate

    # Create basic project structure
    uv init .
    uv add --dev pytest
    mkdir src tests
    touch src/__init__.py
    touch src/main.py
    touch tests/__init__.py
    rm main.py

    # Create initial commit
    git add .
    git commit -m "Initial commit: Project setup"

    echo "Project '$1' created successfully in $PROJECT_DIR"
}

alias mkpy='create_py_project'