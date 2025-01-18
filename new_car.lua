Wheel = Object.extend(Object)

function Wheel.new(
    self,
    world,
    car,
    local_x,
    local_y,
    width,
    length,
    revolving,
    powered
)
    self.car = car
    self.local_pos = Vector2D(local_x, local_y)
    self.revolving = revolving
    self.powered = powered

    local init_pos = self.car:getWorldVector(self.local_pos)
    self.body = love.physics.newBody(world, init_pos.x, init_pos.y, "dynamic")
    self.body:setAngle(self.car.body:getAngle())

    local shape = love.physics.newRectangleShape(width/2, height/2)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setSensor(true)

    if self.revolving then
        local joint = love.physics.newRevoluteJoint(self.car.body, self.body, init_pos.x, init_pos.y, false)
        -- unable to set: enableMotor=False to control the wheel's angle manually
        -- unable to assign joint to world (maybe don't need to)
    else
        local joint = love.physics.newPrismaticJoint(self.car.body, self.body, init_pos.x, init_pos.y, 1, 0, false)
        -- unable to set: enableLimit=True
        -- unable to: joint.lowertranslation = joint.uppertranslation = 0
        -- unable to assign joint to world (maybe don't need to)
    end
end

function Wheel.setAngle(self, local_angle_rad)
    self.body:setAngle(self.car.body:getAngle() + local_angle_rad)
end

function Wheel.getLocalVelocity(self)
    local vel_x, vel_y = self.car.body:getLinearVelocityFromLocalPoint(self.local_pos.x, self.local_pos.y)
    local local_vel_x, local_vel_y = self.car.body:getLocalVector(vel_x, vel_y)
    return Vector2D(local_vel_x, local_vel_y)
end

function Wheel.getDirectionVector(self)
    local local_y = 1
    if self:getLocalVelocity().y < 0
        local_y = -1
    end
    local dir_x, dir_y = self.body:getWorldVector(0, local_y)
    return Vector2D(dir_x, dir_y)
end

function Wheel.killSideWaysVelocity(self)
    local vel_x, vel_y = self.body:getLinearVelocity()
    local velocity = Vector2D(vel_x, vel_y)
    local sideways_axis = self:getDirectionVector()
    sideways_axis:scale(velocity:dot_product(sideways_axis)) -- the "kill velocity" vector
    self.body:setLinearVelocity(sideways_axis.x, sideways_axis.y)
end


Car = Object.extend(Object)

function Car.new(
    self,
    world,
    width,
    length,
    init_x,
    init_y,
    init_angle_rad,
    max_steer_angle,
    max_speed,
    wheel_power_newtons,
    wheel_length,
    wheel_width,
    wheel_x_translate,
    wheel_y_translate,
)
    self.steer = "NONE"
    self.accelerate = "NONE"
    self.max_steer_angle = max_steer_angle
    self.max_speed = max_speed
    self.wheel_power_newtons = wheel_power_newtons
    self.wheel_angle = 0

    self.body = love.physics.newBody(world, init_x, init_y, "dynamic")
    self.body:setAngle(init_angle_rad)
    self.body:setLinearDamping(0.15)
    self.body:setBullet(true)
    self.body:setAngularDamping(0.3)

    local shape = love.physics.newRectangleShape(width/2, length/2)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setFriction(0.3) -- friction when rubbing against other shapes
    self.fixture:setRestitution(0.4) -- amount of force feedback on collision (bounce at > 0)

    local fl_wheel = Wheel(world, self, -wheel_x_translate, wheel_y_translate, wheel_width, wheel_length, true, true)
    local fr_wheel = Wheel(world, self, wheel_x_translate, wheel_y_translate, wheel_width, wheel_length, true, true)
    local bl_wheel = Wheel(world, self, -wheel_x_translate, -wheel_y_translate, wheel_width, wheel_length, false, false)
    local br_wheel = Wheel(world, self, wheel_x_translate, -wheel_y_translate, wheel_width, wheel_length, false, false)
    self.wheels = {fl_wheel, fr_wheel, bl_wheel, br_wheel}
end



var gamejs = require('gamejs');
var box2d = require('./Box2dWeb-2.1.a.3');
var vectors = require('gamejs/utils/vectors');
var math = require('gamejs/utils/math');

var STEER_NONE=0;
var STEER_RIGHT=1;
var STEER_LEFT=2;

var ACC_NONE=0;
var ACC_ACCELERATE=1;
var ACC_BRAKE=2;

var WIDTH_PX=600;   //screen width in pixels
var HEIGHT_PX=400; //screen height in pixels
var SCALE=15;      //how many pixels in a meter
var WIDTH_M=WIDTH_PX/SCALE; //world width in meters. for this example, world is as large as the screen
var HEIGHT_M=HEIGHT_PX/SCALE; //world height in meters
var KEYS_DOWN={}; //keep track of what keys are held down by the player
var b2world;

//initialize font to draw text with
var font=new gamejs.font.Font('16px Sans-serif');

//key bindings
var BINDINGS={accelerate:gamejs.event.K_UP, 
              brake:gamejs.event.K_DOWN,      
              steer_left:gamejs.event.K_LEFT, 
               steer_right:gamejs.event.K_RIGHT}; 


var BoxProp = function(pars){
    /*
   static rectangle shaped prop
     
     pars:
     size - array [width, height]
     position - array [x, y], in world meters, of center
    */
    this.size=pars.size;
    
    //initialize body
    var bdef=new box2d.b2BodyDef();
    bdef.position=new box2d.b2Vec2(pars.position[0], pars.position[1]);
    bdef.angle=0;
    bdef.fixedRotation=true;
    this.body=b2world.CreateBody(bdef);
    
    //initialize shape
    var fixdef=new box2d.b2FixtureDef;
    fixdef.shape=new box2d.b2PolygonShape();
    fixdef.shape.SetAsBox(this.size[0]/2, this.size[1]/2);
    fixdef.restitution=0.4; //positively bouncy!
    this.body.CreateFixture(fixdef);
    return this;  
};


Car.prototype.getPoweredWheels=function(){
    //return array of powered wheels
    var retv=[];
    for(var i=0;i<this.wheels.length;i++){
        if(this.wheels[i].powered){
            retv.push(this.wheels[i]);
        }
    }
    return retv;
};

Car.prototype.getLocalVelocity=function(){
    /*
    returns car's velocity vector relative to the car
    */
    var retv=this.body.GetLocalVector(this.body.GetLinearVelocityFromLocalPoint(new box2d.b2Vec2(0, 0)));
    return [retv.x, retv.y];
};

Car.prototype.getRevolvingWheels=function(){
    //return array of wheels that turn when steering
    var retv=[];
    for(var i=0;i<this.wheels.length;i++){
        if(this.wheels[i].revolving){
            retv.push(this.wheels[i]);
        }
    }
    return retv;
};

Car.prototype.getSpeedKMH=function(){
    var velocity=this.body.GetLinearVelocity();
    var len=vectors.len([velocity.x, velocity.y]);
    return (len/1000)*3600;
};

Car.prototype.setSpeed=function(speed){
    /*
    speed - speed in kilometers per hour
    */
    var velocity=this.body.GetLinearVelocity();
    velocity=vectors.unit([velocity.x, velocity.y]);
    velocity=new box2d.b2Vec2(velocity[0]*((speed*1000.0)/3600.0),
                              velocity[1]*((speed*1000.0)/3600.0));
    this.body.SetLinearVelocity(velocity);

};

Car.prototype.update=function(msDuration){
    
        //1. KILL SIDEWAYS VELOCITY
        
        //kill sideways velocity for all wheels
        var i;
        for(i=0;i<this.wheels.length;i++){
            this.wheels[i].killSidewaysVelocity();
        }
    
        //2. SET WHEEL ANGLE
  
        //calculate the change in wheel's angle for this update, assuming the wheel will reach is maximum angle from zero in 200 ms
        var incr=(this.max_steer_angle/200) * msDuration;
        
        if(this.steer==STEER_RIGHT){
            this.wheel_angle=Math.min(Math.max(this.wheel_angle, 0)+incr, this.max_steer_angle) //increment angle without going over max steer
        }else if(this.steer==STEER_LEFT){
            this.wheel_angle=Math.max(Math.min(this.wheel_angle, 0)-incr, -this.max_steer_angle) //decrement angle without going over max steer
        }else{
            this.wheel_angle=0;        
        }

        //update revolving wheels
        var wheels=this.getRevolvingWheels();
        for(i=0;i<wheels.length;i++){
            wheels[i].setAngle(this.wheel_angle);
        }
        
        //3. APPLY FORCE TO WHEELS
        var base_vect; //vector pointing in the direction force will be applied to a wheel ; relative to the wheel.
        
        //if accelerator is pressed down and speed limit has not been reached, go forwards
        if((this.accelerate==ACC_ACCELERATE) && (this.getSpeedKMH() < this.max_speed)){
            base_vect=[0, -1];
        }
        else if(this.accelerate==ACC_BRAKE){
            //braking, but still moving forwards - increased force
            if(this.getLocalVelocity()[1]<0)base_vect=[0, 1.3];
            //going in reverse - less force
            else base_vect=[0, 0.7];
        }
        else base_vect=[0, 0];

        //multiply by engine power, which gives us a force vector relative to the wheel
        var fvect=[this.power*base_vect[0], this.power*base_vect[1]];

        //apply force to each wheel
        wheels=this.getPoweredWheels();
        for(i=0;i<wheels.length;i++){
           var position=wheels[i].body.GetWorldCenter();
           wheels[i].body.ApplyForce(wheels[i].body.GetWorldVector(new box2d.b2Vec2(fvect[0], fvect[1])), position );
        }
        
        //if going very slow, stop - to prevent endless sliding
        if( (this.getSpeedKMH()<4) &&(this.accelerate==ACC_NONE)){
            this.setSpeed(0);
        }

};

/*
 *initialize car and props, start game loop
 */
function main(){
   
    //initialize display
    var display = gamejs.display.setMode([WIDTH_PX, HEIGHT_PX]);
    
    //SET UP B2WORLD
    b2world=new box2d.b2World(new box2d.b2Vec2(0, 0), false);
    
    //set up box2d debug draw to draw the bodies for us.
    //in a real game, car will propably be drawn as a sprite rotated by the car's angle
    var debugDraw = new box2d.b2DebugDraw();
    debugDraw.SetSprite(display._canvas.getContext("2d"));
    debugDraw.SetDrawScale(SCALE);
    debugDraw.SetFillAlpha(0.5);
    debugDraw.SetLineThickness(1.0);
    debugDraw.SetFlags(box2d.b2DebugDraw.e_shapeBit);
    b2world.SetDebugDraw(debugDraw);
    
    //initialize car
    var car=new Car({'width':2,
                    'length':4,
                    'position':[10, 10],
                    'angle':180, 
                    'power':60,
                    'max_steer_angle':20,
                    'max_speed':60,
                    'wheels':[{'x':-1, 'y':-1.2, 'width':0.4, 'length':0.8, 'revolving':true, 'powered':true}, //top left
                                {'x':1, 'y':-1.2, 'width':0.4, 'length':0.8, 'revolving':true, 'powered':true}, //top right
                                {'x':-1, 'y':1.2, 'width':0.4, 'length':0.8, 'revolving':false, 'powered':false}, //back left
                                {'x':1, 'y':1.2, 'width':0.4, 'length':0.8, 'revolving':false, 'powered':false}]}); //back right
    
    //initialize some props to bounce against
    var props=[];
    
    //outer walls
    props.push(new BoxProp({'size':[WIDTH_M, 1],    'position':[WIDTH_M/2, 0.5]}));
    props.push(new BoxProp({'size':[1, HEIGHT_M-2], 'position':[0.5, HEIGHT_M/2]}));
    props.push(new BoxProp({'size':[WIDTH_M, 1],    'position':[WIDTH_M/2, HEIGHT_M-0.5]}));
    props.push(new BoxProp({'size':[1, HEIGHT_M-2], 'position':[WIDTH_M-0.5, HEIGHT_M/2]}));
    
    //pen in the center
    var center=[WIDTH_M/2, HEIGHT_M/2];
    props.push(new BoxProp({'size':[1, 6], 'position':[center[0]-3, center[1]]}));
    props.push(new BoxProp({'size':[1, 6], 'position':[center[0]+3, center[1]]}));
    props.push(new BoxProp({'size':[5, 1], 'position':[center[0], center[1]+2.5]}));
    
    function tick(msDuration) {
        //GAME LOOP
        
        //set car controls according to player input
        if(KEYS_DOWN[BINDINGS.accelerate]){
            car.accelerate=ACC_ACCELERATE;
        }else if(KEYS_DOWN[BINDINGS.brake]){
            car.accelerate=ACC_BRAKE;
        }else{
            car.accelerate=ACC_NONE;
        }
        
        if(KEYS_DOWN[BINDINGS.steer_right]){
            car.steer=STEER_RIGHT;
        }else if(KEYS_DOWN[BINDINGS.steer_left]){
            car.steer=STEER_LEFT;
        }else{
            car.steer=STEER_NONE;
        }
        
        //update car
        car.update(msDuration);
        
        //update physics world
        b2world.Step(msDuration/1000, 10, 8);        
        
        //clear applied forces, so they don't stack from each update
        b2world.ClearForces();
        
        //fill background
        gamejs.draw.rect(display, '#FFFFFF', new gamejs.Rect([0, 0], [WIDTH_PX, HEIGHT_PX]),0)
        
        //let box2d draw it's bodies
        b2world.DrawDebugData();
        
        //fps and car speed display
        display.blit(font.render('FPS: '+parseInt((1000)/msDuration)), [25, 25]);
        display.blit(font.render('SPEED: '+parseInt(Math.ceil(car.getSpeedKMH()))+' km/h'), [25, 55]);
        return;
    };
    function handleEvent(event){
        if (event.type === gamejs.event.KEY_DOWN) KEYS_DOWN[event.key] = true;
            //key release
        else if (event.type === gamejs.event.KEY_UP) KEYS_DOWN[event.key] = false;  
    };
    gamejs.onTick(tick, this);
    gamejs.onEvent(handleEvent);
    
}

gamejs.ready(main);