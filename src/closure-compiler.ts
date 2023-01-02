function replaceSomething(pattern: RegExp | string, replacement: string) {
  return (arg: string) => arg.replace(pattern, replacement);
}

function compose<T>(...fns: ((arg: T) => T)[]) {
  return (arg: T) => fns.reduce((acc, fn) => fn(acc), arg);
}

const replaceArg = compose(
  replaceSomething(/NEXT_IN|NEXT_OUT/g, "NEXT"),
);

if (import.meta.main) {
  const args = Deno.args.map(replaceArg);

  const scriptPath = new URL(import.meta.url).pathname;
  const scriptDir = scriptPath.substring(0, scriptPath.lastIndexOf("/"));
  const closureCompilerPath = `${scriptDir}/closure-compiler.jar`;

  const process = Deno.run({
    cmd: [
      "java",
      "-jar",
      closureCompilerPath,
      ...args,
    ],
    stdout: "inherit",
    stderr: "inherit",
  });

  const status = await process.status();
  Deno.exit(status.code);
}
