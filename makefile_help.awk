BEGIN {
  # Script arguments with proper defaults
  TERMINAL_WIDTH = (width > 0) ? width : 100
  TAB_WIDTH = (tab_width > 0) ? tab_width : 2
  CMD_WIDTH = (cmd_width > 0) ? cmd_width : 16
  ARGS_WIDTH = (args_width > 0) ? args_width : 14
  DESC_MIN_WIDTH = (desc_width > 0) ? desc_width : 28
  DESCRIPTION = (description) ? description : "Define and run application commands with Docker."

  # Color variables
  BOLD = "\033[1m"
  RESET = "\033[0m"
  YELLOW = "\033[33m"
  CYAN = "\033[36m"

  # Calculate dynamic widths based on terminal size
  TOTAL_PREFIX = CMD_WIDTH + ARGS_WIDTH + TAB_WIDTH + 2
  DESC_WIDTH = TERMINAL_WIDTH - TOTAL_PREFIX - 1
  DESC_SPACE_AVAILABLE = DESC_WIDTH - DESC_MIN_WIDTH
  if (DESC_WIDTH < DESC_MIN_WIDTH) DESC_WIDTH = DESC_MIN_WIDTH

  # String variables
  MARGIN = sprintf("%-*s", TAB_WIDTH, "")
  SECTION_TITLE_FORMAT = "\n" BOLD "%s" RESET "\n\n"
  CMD_COL_FORMAT = MARGIN YELLOW "%-" CMD_WIDTH "s" RESET " " CYAN "%-" ARGS_WIDTH "s" RESET " %s\n"
  INDENT_SPACE = MARGIN sprintf("%-*s", CMD_WIDTH + ARGS_WIDTH + 2, "")
  DESCRIPTION_TEXT = "%s\n"
  USAGE_TEXT = "\nUsage:" RESET "\n\n" MARGIN "make " YELLOW "COMMAND" RESET " " CYAN "[ARGUMENTS]" RESET "\n"

  # Print header
  printf(DESCRIPTION_TEXT, DESCRIPTION)
  printf(USAGE_TEXT)
}

# Function for automatic line wrapping
function wrap_text(text, width, indent, result, line, words, word, i, n) {
    if (length(text) == 0) return ""
    if (DESC_SPACE_AVAILABLE < 0) return "\n" text

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
    
    # Add the last line if not empty
    if (length(line) > 0) {
        result = result (result ? "\n" indent : "") line
    }
    
    return result
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
        arg_extracted = substr(description, RSTART + 1, RLENGTH - 2)
        arguments = arguments (arguments ? " " : "") arg_extracted
        
        # Remove the extracted argument from the description
        description = substr(description, 1, RSTART - 1) substr(description, RSTART + RLENGTH)
    }

    gsub(/^[ \t]+|[ \t]+$/, "", description) # Trim whitespace
    gsub(/[ \t]+/, " ", description)         # Normalize spaces

    # Format and print the command with its description
    formatted_desc = wrap_text(description, DESC_WIDTH, INDENT_SPACE)
    
    printf(CMD_COL_FORMAT, command, arguments, formatted_desc)
}

# Process section titles (### Title)
/^###/ {
    section_title = substr($0, 5)
    gsub(/^[ \t]+|[ \t]+$/, "", section_title)
    printf(SECTION_TITLE_FORMAT, section_title)
}

END {
    printf("")
}
