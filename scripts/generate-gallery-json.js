const fs = require('fs');
const path = require('path');

const photosDir = path.join(__dirname, '../photos');
const output = { groups: [] };

fs.readdirSync(photosDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory())
  .forEach(dirent => {
    const groupName = dirent.name;
    const groupPath = path.join(photosDir, groupName);
    const images = fs.readdirSync(groupPath)
      .filter(file => /\.(jpe?g|png|gif)$/i.test(file));
    output.groups.push({
      name: groupName,
      title: groupName.charAt(0).toUpperCase() + groupName.slice(1),
      images
    });
  });

fs.writeFileSync(
  path.join(__dirname, '../data/gallery.json'),
  JSON.stringify(output, null, 4)
);

console.log('gallery.json generated!');
