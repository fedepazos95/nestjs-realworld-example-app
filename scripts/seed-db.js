const commander = require("commander"); // include commander in git clone of commander repo
const program = new commander.Command();
const faker = require("faker");
const dotenv = require("dotenv");
const format = require("pg-format");
const { Client } = require("pg");

dotenv.config();
const client = new Client({
  user: process.env.DATABASE_USERNAME,
  database: process.env.DATABASE_NAME,
  password: process.env.DATABASE_PASSWORD,
});

function validateOptions(options) {
  if (!options.tags) {
    console.log("must specify a valid argument");
    process.exit(1);
  }
}

class TagService {
  constructor() {
    this.entity = "tag";
    this.props = "tag";
  }
  create() {
    return [faker.lorem.word()];
  }
}

const MAP_SERVICES = {
  tags: TagService,
};

function buildValues(count, builder) {
  let values = [];

  for (let i = 0; i < count; i++) {
    values.push(builder());
  }
  return values;
}

function runQuery(query) {
  return new Promise((resolve, reject) => {
    client.query(query, (err, res) => {
      if (err) return reject(err);
      console.log("query successfully executed");
      resolve(res);
    });
  });
}

// Iterate over each options and run the insert query using the entity's service
async function processOptions(options) {
  for (const name of Object.keys(options)) {
    const Service = new MAP_SERVICES[name]();
    const values = buildValues(options[name], Service.create);
    const query = format(
      `INSERT INTO ${Service.entity} (${Service.props}) VALUES %L`,
      values
    );
    await runQuery(query);
  }
}

(async () => {
  console.log("Initializing Postgres Seed Script...");

  // Later we can add more options to process more entities
  program.option("-t, --tags <tags>", "number of tags to insert");
  program.parse(process.argv);
  const options = program.opts();
  validateOptions(options);

  await client.connect();
  await processOptions(options);
  await client.end();

  console.log("Postgres Seed Script successfully executed.");
})();
