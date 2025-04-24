alias reload!='. ~/.zshrc && source ~/.zshrc'

alias cls='clear'
alias py='python3.13'
alias pip='pip3'


# Function to create a Python project using uv
# usage: mkpy <project_name>
create_py_project() {
    if [ -z "$1" ]; then
        echo "Please provide a project name"
        return 1
    fi

    BASE_DIR="$HOME/python_projects"
    mkdir -p "$BASE_DIR"

    # Check if project already exists
    PROJECT_DIR="$BASE_DIR/$1"
    if [ -d "$PROJECT_DIR" ]; then
        echo "Project directory already exists"
        return 1
    fi

    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"

    # Initialize uv project
    uv venv
    source .venv/bin/activate
    uv init .
    uv add --dev pytest
    mkdir src tests
    touch src/__init__.py
    touch src/main.py
    touch tests/__init__.py
    rm main.py

    # Create initial commit
    git add . \
    && git commit -m "Initial commit: Project setup"

    echo "Project '$1' created successfully in $PROJECT_DIR"
}
alias mkpy='create_py_project'


# Function to run a django development server using uv in a relative path to the manage.py file
# usage: djstart <path_to_manage.py>
start_django_uv() {
    if [ -z "$1" ]; then
        # assume the current directory contains manage.py
        PROJECT_DIR=$(pwd)
    else
        # check if the provided path is valid
        if [ ! -d "$1" ]; then
            echo "Invalid directory: $1"
            return 1
        fi
        
        if [ ! -f "$1/manage.py" ]; then
        echo "manage.py not found in the specified directory"
        return 1
        fi
        
        PROJECT_DIR="$1"
    fi
    
    uv run $PROJECT_DIR/manage.py makemigrations --noinput \
    && uv run $PROJECT_DIR/manage.py migrate --noinput \
    && uv run $PROJECT_DIR/manage.py collectstatic --noinput \
    && uv run $PROJECT_DIR/manage.py runserver
}
alias djstart='start_django_uv'


# Function to redeploy a project to fly.io where the fly.toml file is located
# usage: deployfly
deploy_fly() {
    fly deploy \
    && fly logs
}
alias deployfly='deploy_fly'


# Function to stage all changes, commit and push to the current branch. Prompts for a commit message.
# usage: yolo
yolo_push() {
    # Check if there are any changes to commit
    if [[ -z $(git status --porcelain) ]]; then
        echo "No changes to commit"
        return 1
    fi

    # Stage all changes
    git add .

    # Prompt for a commit message
    read "?Enter commit message: " commit_message
    if [[ -z "$commit_message" ]]; then
        echo "Commit message cannot be empty. Aborting."
        return 1
    fi

    git commit -m "$commit_message" && git push

}
alias yolo='yolo_push'