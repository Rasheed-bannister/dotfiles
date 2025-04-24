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
    
    uv run $PROJECT_DIR/manage.py makemigrations --noinput
    uv run $PROJECT_DIR/manage.py migrate --noinput
    uv run $PROJECT_DIR/manage.py collectstatic --noinput
    uv run $PROJECT_DIR/manage.py runserver
}

alias djstart='start_django_uv'

# Function to redeploy a project to fly.io where the fly.toml file is located
# usage: deployfly
deploy_fly() {
    
    fly deploy
    fly logs
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
        # Optionally unstage changes
        # git reset
        return 1
    fi

    # Commit and push to the current branch
    git commit -m "$commit_message" && git push

    echo "Changes committed and pushed successfully"
}

alias yolo='yolo_push'