BEGIN { FS = "|" }

function colored(c, s) {
  return "\033[1;" c "m" s "\033[0m "
}

function printfln(ln, of) {
  for(c = (length(ln)-of) % TPUT_COLS; c < TPUT_COLS; c++) {
    ln = ln " "
  }

  print(ln)
}

{
  oldsum = sum;
  sum += $0;

  if (oldsum == sum && $2 && length($2) > 1) {
    line=sprintf("%s%12s %s%s", colored($3+0, "█"), $1, colored($3+0, "::"), $2);
    printfln(line, 22)
  }
}