let config = {
    type: Phaser.AUTO,
    width: 800,
    height: 760,
    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 1200 },
            debug: false
        }
    },
    scene: {
        preload: preload,
        create: create,
        update: update
    }
};

let game = new Phaser.Game(config);
let ground;
let stars;
let health = 4;
const TILE_WIDTH = 40;
const TILE_HEIGHT = TILE_WIDTH;

function preload ()
{
    this.load.image('player', './assets/player.png');
    this.load.image('ground', './assets/ground.png');
    this.load.text('map', './assets/map.txt');
    this.load.image('star', './assets/star.png');
    document.getElementById("WIN_TEXT").style.display = "none";
    document.getElementById("LOSE_TEXT").style.display = "none";
    document.getElementById("life").innerText = health;
}

function collectStar (player, star)
{
    star.disableBody(true, true);
    let val = parseInt(document.getElementById("score").innerText);
    val++;
    document.getElementById("score").innerText = val;
    if(val == maxScore){
        console.log("win");
        document.getElementById("WIN_TEXT").style.display = "block";
    }
}

function create ()
{
    let playerBody = this.physics.add.sprite(100, 450, 'player'); 
   
    player = new Player(playerBody);
    
    
    ground = this.physics.add.staticGroup();
    this.physics.add.collider(playerBody, ground);
    this.cameras.main.startFollow(playerBody, false, 1, 0, 0, 150);

    stars = this.physics.add.group();
    this.physics.add.collider(stars, ground);
    this.physics.add.overlap(player.body, stars, collectStar, null, this);

    loadLevel(this.cache.text.get('map'));
}


const ON_GROUND = 0;
const IN_AIR = 1;
let maxScore = 0;

function loadLevel(mapText){
    const lines = mapText.trim().split('\n');
    for(let i=0; i< lines.length; i++){
        const columns = lines[i].trim()
        for(let j=0; j<columns.length; j++){
            columns[j] = columns[j].trim();
            if(columns[j] == 1){
                ground.create(j * TILE_WIDTH, i * TILE_HEIGHT,'ground')
            }
            else if (columns[j] == 2){
                player.body.x = j * TILE_WIDTH;
                player.body.y = i * TILE_HEIGHT;
            }else if (columns[j] == 4){
                stars.create(j * TILE_WIDTH, i * TILE_HEIGHT,'star')
                maxScore += 1;
            }
                
        }
    }
    document.getElementById("maxScore").innerText = maxScore;
}

class Player{
    constructor(body){
        this.startPositionX = 100;
        this.startPositionY = 450;
        this.body = body;
        this.state = ON_GROUND;
        this.velocity = 160;
        this.jumpVelocity = 600;
        this.maxHealt = 3;
        this.currentHealth = this.maxHealt;
        this.resetPosition();
        
    }

    resetPosition(){
        this.body.x = this.startPositionX;
        this.body.y = this.startPositionY;
    }
    checkState(){
        if(this.body.body.touching.down){
            this.state = ON_GROUND;
        }else{
            this.state = IN_AIR;
        }
    }

    update(cursors){
       
        this.checkState();
        if(this.body.y + this.body.height / 2 >= config.height){
            health -= 1;
            document.getElementById("life").innerText = health;
            if (health <= 0){
                console.log("lost");
                document.getElementById("LOSE_TEXT").style.display = "block";
                destroy();
            }else{
                this.resetPosition();
            }
        }


        if (cursors.left.isDown){
            this.body.setVelocityX(-this.velocity);
        }
        else if (cursors.right.isDown){
            this.body.setVelocityX(this.velocity);
        }
        else{
            this.body.setVelocityX(0); 
        }
        
        if (cursors.up.isDown && this.state == ON_GROUND) {
            this.body.setVelocityY(-this.jumpVelocity);
            this.state = IN_AIR;
        }


    }

}


function update ()
{
    
    //this.cameras.cameras[0]._x = -player.body.x + config.width / 2;
    let cursors = this.input.keyboard.createCursorKeys();
    player.update(cursors);
    console.log()
}