const fs = require("fs");
const path = require("path");
const luaparse = require("luaparse");

function translate(src) {
	return src
		.replace(/\/\*[\s\S]*?\*\//g, (m) => "--[==[" + m.slice(2, -2) + "]==]")
		.replace(/\/\//g, "--")
		.replace(/!=/g, "~=")
		.replace(/&&/g, " and ")
		.replace(/\|\|/g, " or ")
		.replace(/!(?!=)/g, " not ")
		.replace(/\bcontinue\b/g, "do end");
}

function collect(target, out) {
	if (!fs.statSync(target).isDirectory()) {
		if (target.endsWith(".lua")) out.push(target);
		return out;
	}
	for (const entry of fs.readdirSync(target)) collect(path.join(target, entry), out);
	return out;
}

const root = path.resolve(__dirname, "..");
const targets = process.argv.length > 2 ? process.argv.slice(2) : [path.join(root, "gamemode"), path.join(root, "entities")];
const files = [];
for (const target of targets) collect(path.resolve(target), files);

let failures = 0;
for (const file of files) {
	try {
		luaparse.parse(translate(fs.readFileSync(file, "utf8")), { luaVersion: "LuaJIT", comments: false });
	} catch (err) {
		failures++;
		console.log(`FAIL ${path.relative(root, file)}: ${err.message}`);
	}
}
console.log(`${files.length} files checked, ${failures} failed`);
process.exit(failures ? 1 : 0);
