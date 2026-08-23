const fs = require("fs");
const path = require("path");

const BASE_PATH = path.join(__dirname, "../src");

const BLACKLISTED_DIRS = [
	toPosix(path.join(BASE_PATH, "ui")),
	toPosix(path.join(BASE_PATH, "startup")),
];

function toPosix(p) {
	return p.split(path.sep).join("/");
}

function toPascalCase(str) {
	return str.charAt(0).toUpperCase() + str.slice(1);
}

function getVirtualPath(filepath) {
	const relativePath = path.relative(BASE_PATH, filepath);
	const parts = relativePath.split(path.sep);

	const filename = path.basename(filepath, ".luau");
	const filenameLower = filename.toLowerCase();

	const isServer = filenameLower.includes("server");
	const isClient = filenameLower.includes("client");

	const folderName =
		parts.length > 1
			? toPascalCase(parts[parts.length - 2])
			: "";

	let name;

	if (filename === "init") {
		name = folderName;
	} else if (
		["server", "client", "utils", "types"].includes(filenameLower)
	) {
		name = folderName + toPascalCase(filename);
	} else {
		name = filename;
	}

	return {
		isInit: filename === "init",
		isNetwork: parts[0]?.toLowerCase() === "network",

		target:
			isServer
				? "ServerScriptService"
				: "ReplicatedStorage",

		folder: parts.slice(0, -1).map(toPascalCase),

		name,

		file:
			filename === "init"
				? toPosix(
					path.join(
						"src",
						...parts.slice(0, -1)
					)
				)
				: toPosix(
					path.join(
						"src",
						...parts
					)
				),
	};
}

const tree = {
	name: "AnimalHospitalAHHGame",

	tree: {
		$className: "DataModel",

		ReplicatedStorage: {
			Shared: {
				$className: "Folder",

				Services: {
					$className: "Folder",
				},

				Classes: {
					$className: "Folder",
				},

				Modules: {
					$className: "Folder",
				},
			},

			Network: {
				$className: "Folder",
			},

			Packages: {
				$path: "Packages",
			},

			UI: {
				$path: "src/ui",
			},
		},

		ServerScriptService: {
			Server: {
				$path: "src/startup/Server.server.luau",
			},

			Services: {
				$className: "Folder",
			},

			Classes: {
				$className: "Folder",
			},

			Modules: {
				$className: "Folder",
			},
		},

		StarterPlayer: {
			StarterPlayerScripts: {
				Client: {
					$path: "src/startup/Client.client.luau",
				},
			},
		},
	},
};

const sharedRoot =
	tree.tree.ReplicatedStorage.Shared;

const networkRoot =
	tree.tree.ReplicatedStorage.Network;

const serverRoot =
	tree.tree.ServerScriptService;

// Recursively walk all files.

function walk(dir, callback) {
	if (BLACKLISTED_DIRS.includes(toPosix(dir))) {
		return;
	}

	fs.readdirSync(dir, {
		withFileTypes: true,
	}).forEach((entry) => {
		const full = path.join(dir, entry.name);

		if (entry.isDirectory()) {
			walk(full, callback);
		} else if (
			entry.isFile() &&
			entry.name.endsWith(".luau")
		) {
			callback(full);
		}
	});
}

walk(BASE_PATH, (filepath) => {
	const {
		target,
		folder,
		name,
		file,
		isInit,
		isNetwork,
	} = getVirtualPath(filepath);

	/*
		NETWORK
		-------
		src/network/Foo.luau

		becomes:

		ReplicatedStorage
		└── Network
		    └── Foo
	*/

	if (isNetwork) {
		const relativePath = path.relative(
			path.join(BASE_PATH, "network"),
			filepath
		);

		const networkParts =
			relativePath.split(path.sep);

		const filename =
			path.basename(
				filepath,
				".luau"
			);

		let current = networkRoot;

		for (
			let i = 0;
			i < networkParts.length - 1;
			i++
		) {
			const part = toPascalCase(
				networkParts[i]
			);

			if (!current[part]) {
				current[part] = {
					$className: "Folder",
				};
			}

			current = current[part];
		}

		current[filename] = {
			$path: file,
		};

		return;
	}

	/*
		SERVER / SHARED
	*/

	const root =
		target === "ServerScriptService"
			? serverRoot
			: sharedRoot;

	if (isInit) {
		const parent = folder
			.slice(0, -1)
			.reduce((acc, part) => {
				if (!acc[part]) {
					acc[part] = {
						$className: "Folder",
					};
				}

				return acc[part];
			}, root);

		parent[name] = {
			$path: file,
		};

		return;
	}

	let current = root;

	for (const part of folder) {
		if (!current[part]) {
			current[part] = {
				$className: "Folder",
			};
		}

		current = current[part];
	}

	current[name] = {
		$path: file,
	};
});

fs.writeFileSync(
	"default.project.json",
	JSON.stringify(tree, null, 2)
);

console.log(
	"✅ default.project.json generated."
);
