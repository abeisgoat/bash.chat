BEGIN { FS = "|" }

function colored(c, s) {
  return "\033[1;" c "m" s "\033[0m "
}

{
  oldsum = sum;
  sum += $0;

  if (oldsum == sum && $2 && length($2) > 1) {
    printf("%s%12s %s", colored($3+0, "█"), $1, colored($3+0, "::"));
    printf("%s\n", $2);
  }
}