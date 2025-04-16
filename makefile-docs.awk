# =========================================================
# Makefile Help Formatter
#
# Description: Formats makefile targets as a well-formatted help message
# Usage: make help | awk -f makefile_help.awk [parameters]
# Parameters:
#   width               - Terminal width (default: 100)
#   tab_width           - Tab indentation width (default: 4)
#   command_width       - Width for command column (default: 16)
#   arguments_width     - Width for arguments column (default: 14)
#   description_width   - Minimum width for description (default: 28)
#   description         - Custom description text
#   help                - Custom help text
#   usage               - Custom usage text
#
# Created by: https://github.com/vidardev/
# =========================================================

# Helper functions
function trim(str) {
    gsub(/^[ \t]+|[ \t]+$/, "", str)
    return str
}

function normalize_spaces(str) {
    gsub(/[ \t]+/, " ", str)
    return trim(str)
}

# Function for automatic line wrapping
function wrap_text(text, width, available_width, indent) {
    if (length(text) == 0) return ""
    if (available_width <= 0) return "\n" margin_space text
        
    result = ""
    line = ""
    n = split(text, words, /[ \t]+/)
    
    for (i = 1; i <= n; i++) {
        word = words[i]
        if (word == "") continue
        
        if (length(line) == 0) {
            line = word
        } else if (length(line) + length(word) + 1 <= width) {
            line = line " " word
        } else {
            result = result (result ? "\n" indent : "") line
            line = word
        }
    }
    
    if (length(line) > 0) {
        result = result (result ? "\n" indent : "") line
    }
    
    return result
}

function replace_text(text, search_str, replace_str) {
    if (!search_str || length(search_str) == 0) return text
    gsub(search_str, replace_str, text)
    return text
}

BEGIN {
    # ANSI color codes
    BOLD = "\033[1m"
    RESET = "\033[0m"
    COLOR_COMMAND = "\033[33m"
    COLOR_ARGUMENTS = "\033[36m"

    # Script arguments with proper defaults
    terminal_width = (width > 0) ? width : 100
    tab_width = (tab_width > 0) ? tab_width : 4
    command_width = (command_width > 0) ? command_width : 16
    arguments_width = (arguments_width > 0) ? arguments_width : 14
    description_min_width = (description_min_width > 0) ? description_min_width : 28

    custom_description = (description) ? description : "Define and run application commands with Docker."
    custom_help = (help) ? help : "Use %s to display this help."
    custom_usage = (usage) ? usage : "Usage:"

    # Calculate dynamic widths based on terminal size
    total_prefix_width = command_width + arguments_width + tab_width + 2
    description_width = terminal_width - total_prefix_width - 1
    available_description_width = description_width - description_min_width
    if (description_width < description_min_width) description_width = description_min_width

    # String formatting constants
    margin_space = sprintf("%-*s", tab_width, "")
    indent_space = margin_space sprintf("%-*s", command_width + arguments_width + 2, "")
    line_return = "\n\n"

    section_title_format = "\n" BOLD "%s" RESET line_return
    command_format = margin_space COLOR_COMMAND "%-" command_width "s" RESET " " COLOR_ARGUMENTS "%-" arguments_width "s" RESET " %s\n"
    description_format = "%s" line_return
    usage_format = BOLD "%s" RESET line_return margin_space "make " COLOR_COMMAND "COMMAND" RESET " " COLOR_ARGUMENTS "[ARGUMENTS]" RESET "\n"
    help_format = "\n%s" line_return

    # Print header
    printf(description_format, custom_description)
    printf(usage_format, custom_usage)
}

# Process makefile commands
/^[a-zA-Z0-9_.-]+:[^#]*##/ {
    command = $1
    description = $2
    arguments = ""

    # Clean the command name (remove ':')
    sub(/:$/, "", command)

    # Extract arguments from description
    while (match(description, /\[([^]]+)\]/)) {
        extracted_arg = substr(description, RSTART + 1, RLENGTH - 2)
        arguments = arguments (arguments ? " " : "") extracted_arg
        
        # Remove the extracted argument from the description
        description = substr(description, 1, RSTART - 1) substr(description, RSTART + RLENGTH)
    }

    # Clean the description text
    description = trim(description)
    description = normalize_spaces(description)

    # Format and print the command with its description
    formatted_description = wrap_text(description, description_width, available_description_width, indent_space)
    printf(command_format, command, arguments, formatted_description)
}

# Process section titles (### Title)
/^###/ {
    section_title = substr($0, 5)
    section_title = trim(section_title)
    printf(section_title_format, section_title)
}

END {
    help_text = replace_text(custom_help, "%s", "\"make " COLOR_COMMAND "help" RESET "\"")
    printf(help_format, help_text)
}