player.onChat("render", function () {
    let origin = player.position()
    let wallLength = 20;
    let wallHeight = 5;
    let towerSize = 5;
    let towerHeight = 13;
    let moatWidth = 3;


    create_wall(origin, STONE, wallLength, wallHeight);
    create_towers(origin, STONE_BRICKS, towerSize, towerHeight, wallLength, wallHeight);
    create_passage(origin, wallLength, wallHeight);
    create_tower_ladders(origin, towerSize, towerHeight, wallLength);
    create_moat(origin, wallLength, towerSize, moatWidth);
    create_bridges(origin, wallLength, moatWidth, towerSize, PLANKS_OAK);
    fillCastleAreaWithCobblestone(origin, wallLength, towerSize, moatWidth);
})

function create_wall(start: Position, base_material: Block, length: number, height: number) {
    blocks.fill(base_material, start, start.add(pos(length, height, 0)), FillOperation.Replace);
    blocks.fill(base_material, start, start.add(pos(0, height, length)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(length, 0, 0)), start.add(pos(length, height, length)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(0, 0, length)), start.add(pos(length, height, length)), FillOperation.Replace);

    blocks.fill(base_material, start.add(pos(-1, 0, -1)), start.add(pos(-1, height, length + 1)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(-1, 0, -1)), start.add(pos(length + 1, height, -1)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(length + 1, 0, -1)), start.add(pos(length + 1, height, length + 1)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(-1, 0, length + 1)), start.add(pos(length + 1, height, length + 1)), FillOperation.Replace);

    blocks.fill(base_material, start.add(pos(1, 0, 1)), start.add(pos(1, height, length - 1)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(1, 0, 1)), start.add(pos(length - 1, height, 1)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(length - 1, 0, 1)), start.add(pos(length - 1, height, length - 1)), FillOperation.Replace);
    blocks.fill(base_material, start.add(pos(1, 0, length - 1)), start.add(pos(length - 1, height, length - 1)), FillOperation.Replace);

    let entranceWidth = 2; // Width of the entrance
    let wallThickness = 3; // The thickness of the wall
    let halfEntranceWidth = Math.floor(entranceWidth / 2);

    // Create entrances on each wall, ensuring to cut through all layers
    for (let w = -1; w < wallThickness; w++) {
        blocks.fill(AIR, start.add(pos(length / 2 - halfEntranceWidth, 0, -w)), start.add(pos(length / 2 + halfEntranceWidth, height / 2, -w)), FillOperation.Replace); // Entrance on the front wall
        blocks.fill(AIR, start.add(pos(length / 2 - halfEntranceWidth, 0, length + w)), start.add(pos(length / 2 + halfEntranceWidth, height / 2, length + w)), FillOperation.Replace); // Entrance on the back wall
        blocks.fill(AIR, start.add(pos(-w, 0, length / 2 - halfEntranceWidth)), start.add(pos(-w, height / 2, length / 2 + halfEntranceWidth)), FillOperation.Replace); // Entrance on the left wall
        blocks.fill(AIR, start.add(pos(length + w, 0, length / 2 - halfEntranceWidth)), start.add(pos(length + w, height / 2, length / 2 + halfEntranceWidth)), FillOperation.Replace); // Entrance on the right wall
    }

    let barrierMaterial = OAK_FENCE; // Replace FENCE with the desired block type for your barriers

    // Adding barriers on top of the external walls
    blocks.fill(barrierMaterial, start.add(pos(1, height + 1, 1)), start.add(pos(length + 1, height + 1, 1)), FillOperation.Replace); // Top of the front wall
    blocks.fill(barrierMaterial, start.add(pos(-1, height + 1, -1)), start.add(pos(length - 1, height + 1, -1)), FillOperation.Replace); // Top of the front wall

    blocks.fill(barrierMaterial, start.add(pos(1, height + 1, length + 1)), start.add(pos(length + 1, height + 1, length + 1)), FillOperation.Replace); // Top of the back wall
    blocks.fill(barrierMaterial, start.add(pos(-1, height + 1, length - 1)), start.add(pos(length - 1, height + 1, length - 1)), FillOperation.Replace); // Top of the back wall

    blocks.fill(barrierMaterial, start.add(pos(1, height + 1, 1)), start.add(pos(1, height + 1, length + 1)), FillOperation.Replace); // Top of the left wall
    blocks.fill(barrierMaterial, start.add(pos(-1, height + 1, -1)), start.add(pos(-1, height + 1, length - 1)), FillOperation.Replace); // Top of the left wall

    blocks.fill(barrierMaterial, start.add(pos(length + 1, height + 1, 1)), start.add(pos(length + 1, height + 1, length + 1)), FillOperation.Replace); // Top of the right wall
    blocks.fill(barrierMaterial, start.add(pos(length - 1, height + 1, -1)), start.add(pos(length - 1, height + 1, length - 1)), FillOperation.Replace); // Top of the right wall
}

function create_passage(start: Position, length: number, height: number) {
    blocks.fill(AIR, start, start.add(pos(length, 1, 0)), FillOperation.Replace);
    blocks.fill(AIR, start, start.add(pos(0, 1, length)), FillOperation.Replace);
    blocks.fill(AIR, start.add(pos(length, 0, 0)), start.add(pos(length, 1, length)), FillOperation.Replace);
    blocks.fill(AIR, start.add(pos(0, 0, length)), start.add(pos(length, 1, length)), FillOperation.Replace);

    blocks.fill(AIR, start.add(pos(0, height + 1, 0)), start.add(pos(length, height + 2, 0)), FillOperation.Replace);
    blocks.fill(AIR, start.add(pos(0, height + 1, 0)), start.add(pos(0, height + 2, length)), FillOperation.Replace);
    blocks.fill(AIR, start.add(pos(length, height + 1, 0)), start.add(pos(length, height + 2, length)), FillOperation.Replace);
    blocks.fill(AIR, start.add(pos(0, height + 1, length)), start.add(pos(length, height + 2, length)), FillOperation.Replace);
}

function create_towers(start: Position, base_material: Block, size: number, height: number, wallLength: number, wallHeight: number) {
    let towerOffset = Math.floor(size / 2);
    let holeSize = 1; // Hole size
    let additionalHoleSize = 3; // Additional hole size
    let holeHeightOffset = 2; // Height offset for the additional hole

    // Creating towers at the corners
    for (let i = 0; i < 4; i++) {
        let x = (i % 2 === 0) ? -towerOffset : wallLength - towerOffset;
        let z = (i < 2) ? -towerOffset : wallLength - towerOffset;

        blocks.fill(base_material, start.add(pos(x, 0, z)), start.add(pos(x + size - 1, height, z + size - 1)), FillOperation.Replace);

        // Creating the roof
        create_roof(start.add(pos(x, height + 1, z)), PLANKS_OAK, size);

        // Creating windows in the tower
        create_windows(start.add(pos(x, 0, z)), size, height, wallHeight);

        // Creating a ladder (1x1) from the ground to just below the additional hole (3x3)
        for (let y = 0; y < wallHeight + holeHeightOffset - 1; y++) {
            blocks.place(LADDER, start.add(pos(x + Math.floor(size / 2), y, z + Math.floor(size / 2))));
        }

        // Creating a hole in the tower (1x1 in the center)
        let holeX = x + Math.floor((size - holeSize) / 2);
        let holeZ = z + Math.floor((size - holeSize) / 2);
        blocks.fill(AIR, start.add(pos(holeX, 0, holeZ)), start.add(pos(holeX + holeSize - 1, height, holeZ + holeSize - 1)), FillOperation.Replace);

        // Creating an additional hole (3x3) starting from 2 blocks above wallHeight to the top
        if (height >= wallHeight + holeHeightOffset) {
            let additionalHoleX = x + Math.floor((size - additionalHoleSize) / 2);
            let additionalHoleZ = z + Math.floor((size - additionalHoleSize) / 2);
            blocks.fill(AIR, start.add(pos(additionalHoleX, wallHeight + holeHeightOffset - 1, additionalHoleZ)), start.add(pos(additionalHoleX + additionalHoleSize - 1, height, additionalHoleZ + additionalHoleSize - 1)), FillOperation.Replace);
        }
    }
}

function create_tower_ladders(origin: Position, towerSize: number, towerHeight: number, wallLength: number) {
    let towerOffset = Math.floor(towerSize / 2);

    // Loop to place ladders in each of the four towers
    for (let i = 0; i < 4; i++) {
        let x = (i % 2 === 0) ? -towerOffset : wallLength - towerOffset;
        let z = (i < 2) ? -towerOffset : wallLength - towerOffset;

        // Placing ladder inside the tower
        for (let y = 0; y < towerHeight; y++) {
            let ladderX = x + Math.floor(towerSize / 2);
            let ladderZ = z + Math.floor(towerSize / 2);
            blocks.place(LADDER, origin.add(pos(ladderX, y, ladderZ)));
        }
    }
}

function create_roof(start: Position, material: Block, baseSize: number) {
    let currentSize = baseSize + 2; // Starting size of the roof

    for (let y = 0; currentSize > 0; y++, currentSize -= 2) {
        let offset = Math.floor((baseSize - currentSize) / 2);
        blocks.fill(material, start.add(pos(offset, y, offset)), start.add(pos(offset + currentSize - 1, y, offset + currentSize - 1)), FillOperation.Replace);
    }
}

function create_windows(start: Position, size: number, height: number, wallHeight: number) {
    let windowWidth = 1; // Window width
    let windowHeight = height - wallHeight - 5; // Window height: from 4 blocks above the wall to 1 block before the top of the tower

    // Check if the window is not too small
    if (windowHeight < 1) {
        return;
    }

    // Create windows on each side of the tower
    for (let side = 0; side < 4; side++) {
        let x = 0, z = 0;
        if (side === 0) { // North
            x = Math.floor((size - windowWidth) / 2);
            z = 0;
        } else if (side === 1) { // East
            x = size - 1;
            z = Math.floor((size - windowWidth) / 2);
        } else if (side === 2) { // South
            x = Math.floor((size - windowWidth) / 2);
            z = size - 1;
        } else if (side === 3) { // West
            x = 0;
            z = Math.floor((size - windowWidth) / 2);
        }

        blocks.fill(GLASS, start.add(pos(x, wallHeight + 4, z)), start.add(pos(x, wallHeight + 4 + windowHeight, z)), FillOperation.Replace);
    }
}

function create_moat(start: Position, length: number, towerSize: number, moatWidth: number) {
    let moatDepth = -1; // Depth of the moat, 1 block below ground level

    let offset = Math.floor(towerSize / 2) + moatWidth; // Moat offset taking towers into account

    // Moat around the fortress
    for (let i = -offset; i <= length + offset; i++) {
        for (let j = -offset; j <= length + offset; j++) {
            // Check if we're on the edge of the moat
            if ((i >= -offset && i <= -offset + moatWidth - 1) ||
                (i >= length + offset - moatWidth + 1 && i <= length + offset) ||
                (j >= -offset && j <= -offset + moatWidth - 1) ||
                (j >= length + offset - moatWidth + 1 && j <= length + offset)) {
                blocks.fill(WATER, start.add(pos(i, moatDepth, j)), start.add(pos(i, moatDepth, j)), FillOperation.Replace);
            }
        }
    }
}

function fillCastleAreaWithCobblestone(start: Position, length: number, towerSize: number, moatWidth: number) {
    let groundLevel = -1;
    let offset = Math.floor(towerSize / 2) + moatWidth;

    blocks.fill(COBBLESTONE,
        start.add(pos(-offset + moatWidth, groundLevel, -offset + moatWidth)),
        start.add(pos(length + offset - moatWidth, groundLevel, length + offset - moatWidth)),
        FillOperation.Replace);
}

function create_bridges(start: Position, length: number, moatWidth: number, towerSize: number, bridgeMaterial: Block) {
    let entranceWidth = 2; // Entrance width
    let halfEntranceWidth = Math.floor(entranceWidth / 2);
    let bridgeLength = moatWidth; // Bridge length equal to moat width
    let bridgeStartDepth = -1; // Depth at which the bridge starts (water surface level)

    // Offset the bridge by the thickness of the outer wall and the width of the tower
    let offset = Math.floor(towerSize / 2);

    // Create bridges in front of each entrance
    blocks.fill(bridgeMaterial, start.add(pos(length / 2 - halfEntranceWidth, bridgeStartDepth, -(moatWidth + offset))), start.add(pos(length / 2 + halfEntranceWidth, bridgeStartDepth, -offset)), FillOperation.Replace); // Front entrance
    blocks.fill(bridgeMaterial, start.add(pos(length / 2 - halfEntranceWidth, bridgeStartDepth, length + offset)), start.add(pos(length / 2 + halfEntranceWidth, bridgeStartDepth, length + moatWidth + offset)), FillOperation.Replace); // Back entrance
    blocks.fill(bridgeMaterial, start.add(pos(-(moatWidth + offset), bridgeStartDepth, length / 2 - halfEntranceWidth)), start.add(pos(-offset, bridgeStartDepth, length / 2 + halfEntranceWidth)), FillOperation.Replace); // Left entrance
    blocks.fill(bridgeMaterial, start.add(pos(length + offset, bridgeStartDepth, length / 2 - halfEntranceWidth)), start.add(pos(length + moatWidth + offset, bridgeStartDepth, length / 2 + halfEntranceWidth)), FillOperation.Replace); // Right entrance
}
