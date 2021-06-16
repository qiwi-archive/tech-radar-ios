const fs = require("fs").promises;
const path = require("path");
const parse = require("csv-parse/lib/sync");

const basePath = path.join(__dirname, "./src/entries");

(async function() {
  const filePath = path.join(__dirname, process.argv[2]);
  console.log("Load - ", filePath)

  const fileContent = await fs.readFile(filePath);
  const records = parse(fileContent, { columns: true });
  records.forEach(async function(element) {
    try {
      const filePath = path.join(
        basePath,
        element.quadrant.toLowerCase(),
        `${element.name
          .replace("/", " ")
          .replace(/^\w/, (c) => c.toUpperCase())}.md`
      );

      const content = `---
ring: ${element.ring.toLowerCase()}
---
${element.description}`

      await fs.writeFile(filePath, content);
    } catch (err) {
      console.log("Element - ", element);
      console.log("Error - ", err);
    }
  });
})();
