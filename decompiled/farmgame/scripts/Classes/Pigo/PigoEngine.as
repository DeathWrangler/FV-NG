package Classes.Pigo
{
   import Engine.Managers.SoundManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.cove.ape.APEngine;
   import org.cove.ape.CollisionEvent;
   import org.cove.ape.Group;
   import org.cove.ape.VectorForce;
   
   public class PigoEngine extends Sprite
   {
      
      private static const PEG_COLLISION_SOUND_ID:String = "pigo_peg_collision";
      
      private static const SIDE_COLLISION_SOUND_ID:String = "pego_side_collision";
      
      private static const TOKEN_COLLISION_SOUND_ID:String = "pego_token_collision";
      
      private static const TOKEN_DROP_SOUND_ID:String = "pigo_token_drop";
      
      private static const TOKEN_DROP_COMPLETE_SOUND_ID:String = "pigo_token_drop_complete";
      
      private static const TOKEN_ELASTICITY:Number = 0.35;
      
      private static const TOKEN_MASS:Number = 0.8;
      
      public static const TOKEN_RADIUS:Number = 12;
      
      private var m_running:Boolean = false;
      
      private var m_group:Group;
      
      private var m_dividers:Array;
      
      private var m_numTokens:int;
      
      private var m_tokens:Dictionary;
      
      private var m_tokenBounds:Rectangle;
      
      private var m_lastPegRowY:Number;
      
      private var m_dropCompleteCallback:Function;
      
      public function PigoEngine(dropCompleteCallback:Function)
      {
         var i:int = 0;
         var j:int = 0;
         var dividerX:Number = NaN;
         var divider:PigoSideParticle = null;
         var pegXOffset:Number = NaN;
         var pegX:Number = NaN;
         var pegY:Number = NaN;
         var sideY:Number = NaN;
         this.m_group = new Group();
         this.m_dividers = new Array();
         this.m_tokens = new Dictionary();
         super();
         this.m_dropCompleteCallback = dropCompleteCallback;
         this.initSounds();
         APEngine.init(1 / 4);
         APEngine.container = this;
         APEngine.addForce(new VectorForce(false,0,5));
         this.m_group.collideInternal = true;
         var numPegsPerRow:int = 5;
         var numPegRows:int = 9;
         var pegRadius:Number = 5;
         var pegXOrigin:Number = 10;
         var pegYOrigin:Number = 100;
         var pegXSpacing:Number = 54;
         var halfPegXSpacing:Number = pegXSpacing / 2;
         var pegYSpacing:Number = halfPegXSpacing;
         var dividerWidth:Number = 4;
         var dividerHeight:Number = 50;
         var dividerY:Number = pegYOrigin + (numPegRows - 1) * pegYSpacing + pegRadius + dividerHeight / 2;
         for(i = 0; i < numPegsPerRow; i++)
         {
            dividerX = pegXOrigin + i * pegXSpacing;
            divider = new PigoSideParticle(dividerX,dividerY,dividerWidth,dividerHeight,0,true);
            this.m_group.addParticle(divider);
            this.m_dividers.push(divider);
         }
         for(i = 0; i < numPegsPerRow; i++)
         {
            for(j = 0; j < numPegRows; j++)
            {
               pegXOffset = j % 2 * (pegXSpacing / 2);
               if(pegXOffset == 0 || i < numPegsPerRow - 1)
               {
                  pegX = pegXOrigin + pegXOffset + i * pegXSpacing;
                  pegY = pegYOrigin + j * pegYSpacing;
                  this.m_group.addParticle(new PigoPegParticle(pegX,pegY,pegRadius,true));
               }
            }
         }
         var numSides:int = numPegRows / 2;
         var sideXLeft:Number = pegXOrigin - pegXSpacing + pegRadius / 2;
         var sideXRight:Number = pegXOrigin + numPegsPerRow * pegXSpacing - pegRadius / 2;
         var sideLength:Number = Math.sqrt(Math.pow(halfPegXSpacing,2) + Math.pow(pegYSpacing,2));
         var sideRotation:Number = 45 * (Math.PI / 180);
         for(i = 0; i < numSides; i++)
         {
            sideY = pegYOrigin + pegYSpacing + i * 2 * pegYSpacing;
            this.m_group.addParticle(new PigoSideParticle(sideXLeft,sideY,sideLength,sideLength,sideRotation,true));
            this.m_group.addParticle(new PigoSideParticle(sideXRight,sideY,sideLength,sideLength,-sideRotation,true));
         }
         var bottomWidth:Number = (numPegsPerRow + 1) * pegXSpacing;
         var bottomHeight:Number = 4;
         var bottomXOrigin:Number = sideXLeft;
         var bottomX:Number = bottomXOrigin + bottomWidth / 2;
         var bottomY:Number = dividerY + dividerHeight / 2;
         this.m_group.addParticle(new PigoSideParticle(bottomX,bottomY,bottomWidth,bottomHeight,0,true,1,0));
         var wallWidth:Number = halfPegXSpacing;
         var wallHeight:Number = bottomY;
         var wallXLeft:Number = sideXLeft - wallWidth / 2;
         var wallXRight:Number = sideXRight + wallWidth / 2;
         var wallY:Number = wallHeight / 2;
         var leftWall:PigoSideParticle = new PigoSideParticle(wallXLeft,wallY,wallWidth,wallHeight,0,true);
         leftWall.visible = false;
         this.m_group.addParticle(leftWall);
         var rightWall:PigoSideParticle = new PigoSideParticle(wallXRight,wallY,wallWidth,wallHeight,0,true);
         rightWall.visible = false;
         this.m_group.addParticle(rightWall);
         this.m_tokenBounds = new Rectangle(bottomXOrigin + TOKEN_RADIUS,0,bottomWidth - TOKEN_RADIUS,bottomY - TOKEN_RADIUS);
         this.m_lastPegRowY = pegY;
         APEngine.addGroup(this.m_group);
      }
      
      public function release() : void
      {
         APEngine.removeGroup(this.m_group);
         this.m_group = null;
         this.m_dividers = null;
         this.m_tokens = null;
         this.m_tokenBounds = null;
         this.m_dropCompleteCallback = null;
      }
      
      private function initSounds() : void
      {
         if(!SoundManager.isMuted())
         {
            if(!SoundManager.getSoundById(PEG_COLLISION_SOUND_ID))
            {
               SoundManager.addSound(PEG_COLLISION_SOUND_ID,Global.getAssetURL("assets/sounds/pigo/sfx_pigo_hit1.mp3"),false);
               SoundManager.addSound(SIDE_COLLISION_SOUND_ID,Global.getAssetURL("assets/sounds/pigo/sfx_pigo_hit2.mp3"),false);
               SoundManager.addSound(TOKEN_COLLISION_SOUND_ID,Global.getAssetURL("assets/sounds/pigo/sfx_pigo_hit3.mp3"),false);
               SoundManager.addSound(TOKEN_DROP_SOUND_ID,Global.getAssetURL("assets/sounds/pigo/sfx_pigo_start.mp3"),false);
               SoundManager.addSound(TOKEN_DROP_COMPLETE_SOUND_ID,Global.getAssetURL("assets/sounds/pigo/sfx_pigo_win.mp3"),false);
            }
         }
      }
      
      private function start() : void
      {
         if(!this.m_running)
         {
            Global.stage.addEventListener(Event.ENTER_FRAME,this.onStageEnterFrame);
            this.m_running = true;
         }
      }
      
      private function stop() : void
      {
         if(this.m_running)
         {
            Global.stage.removeEventListener(Event.ENTER_FRAME,this.onStageEnterFrame);
            this.m_running = false;
         }
      }
      
      private function onStageEnterFrame(event:Event) : void
      {
         var key:Object = null;
         var dropComplete:Boolean = false;
         var token:PigoTokenParticle = null;
         var tokenPosition:Point = null;
         var slotIndex:int = 0;
         APEngine.step();
         APEngine.paint();
         if(this.m_tokens)
         {
            for(key in this.m_tokens)
            {
               dropComplete = false;
               token = key as PigoTokenParticle;
               tokenPosition = this.m_tokens[token] as Point;
               if(token.py == tokenPosition.y)
               {
                  if(token.px == tokenPosition.x && token.py < this.m_lastPegRowY)
                  {
                     token.px += 0.1;
                  }
                  else
                  {
                     slotIndex = this.getSlotIndex(token);
                     token.removeEventListener(CollisionEvent.COLLIDE,this.onTokenCollision);
                     this.m_group.removeParticle(token);
                     delete this.m_tokens[token];
                     --this.m_numTokens;
                     if(this.m_dropCompleteCallback != null)
                     {
                        this.m_dropCompleteCallback(slotIndex);
                     }
                     dropComplete = true;
                     if(!SoundManager.isMuted())
                     {
                        SoundManager.playSound(TOKEN_DROP_COMPLETE_SOUND_ID);
                     }
                  }
               }
               if(!dropComplete)
               {
                  tokenPosition.x = token.px;
                  tokenPosition.y = token.py;
               }
            }
            if(this.m_numTokens <= 0)
            {
               this.stop();
            }
         }
      }
      
      public function dropToken(position:Point) : void
      {
         var tokenX:Number = position.x;
         var tokenY:Number = position.y;
         if(tokenX < this.m_tokenBounds.x)
         {
            tokenX = this.m_tokenBounds.x;
         }
         if(tokenX > this.m_tokenBounds.width)
         {
            tokenX = this.m_tokenBounds.width;
         }
         if(tokenY < this.m_tokenBounds.y)
         {
            tokenY = this.m_tokenBounds.y;
         }
         if(tokenY > this.m_tokenBounds.height)
         {
            tokenY = this.m_tokenBounds.height;
         }
         var token:PigoTokenParticle = new PigoTokenParticle(tokenX,tokenY,TOKEN_RADIUS,false,TOKEN_MASS,TOKEN_ELASTICITY);
         token.addEventListener(CollisionEvent.COLLIDE,this.onTokenCollision,false,0,true);
         this.m_group.addParticle(token);
         this.m_tokens[token] = new Point(Number.NaN,Number.NaN);
         ++this.m_numTokens;
         if(!this.m_running)
         {
            this.start();
         }
         if(!SoundManager.isMuted())
         {
            SoundManager.playSound(TOKEN_DROP_SOUND_ID);
         }
      }
      
      private function onTokenCollision(event:CollisionEvent) : void
      {
         if(!SoundManager.isMuted())
         {
            if(event.collidingItem is PigoPegParticle)
            {
               SoundManager.playSound(PEG_COLLISION_SOUND_ID);
            }
            else if(event.collidingItem is PigoSideParticle)
            {
               SoundManager.playSound(SIDE_COLLISION_SOUND_ID);
            }
            else if(event.collidingItem is PigoTokenParticle)
            {
               SoundManager.playSound(TOKEN_COLLISION_SOUND_ID);
            }
         }
      }
      
      private function getSlotIndex(token:PigoTokenParticle) : int
      {
         var slotIndex:int = 0;
         var currentDivider:PigoSideParticle = null;
         var previousDivider:PigoSideParticle = null;
         var slotFound:Boolean = false;
         var numDividers:int = int(this.m_dividers.length);
         for(var i:int = 0; i < numDividers; i++)
         {
            currentDivider = this.m_dividers[i] as PigoSideParticle;
            if(previousDivider)
            {
               if(token.px < currentDivider.px && token.px > previousDivider.px)
               {
                  slotFound = true;
                  slotIndex = i;
                  break;
               }
            }
            else if(token.px < currentDivider.px)
            {
               slotFound = true;
               slotIndex = i;
               break;
            }
            previousDivider = currentDivider;
         }
         if(!slotFound)
         {
            slotIndex = i;
         }
         return slotIndex;
      }
   }
}

