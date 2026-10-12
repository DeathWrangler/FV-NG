package AvatarMode
{
   import Classes.Animal;
   import Classes.Avatar.FarmAvatar;
   import Classes.Pet;
   import Engine.Helpers.Vector2;
   import fl.motion.easing.Bounce;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class AMPet extends AMActionState
   {
      
      private static const PETTING_URL:String = "assets/overlays/effect_petting.swf";
      
      private const MAX_JUMPS:Number = 2;
      
      private const SCALE_JUMP:Number = 0.1;
      
      protected var m_animal:Animal;
      
      private var m_repeat:Number = 0;
      
      private var m_jumpHeight:int;
      
      private const S_OFFSET:Number = 1.1;
      
      private const Y_OFFSET:Number = 0.8;
      
      private var m_action:String = "";
      
      public function AMPet(avatar:FarmAvatar, resource:Animal, action:String = "")
      {
         super(avatar,resource);
         this.m_animal = resource;
         this.m_jumpHeight = Global.farmGameSettingsManager.getInt("animalMaxJumpHeight",600);
         this.m_action = action;
      }
      
      override public function update(delta:Number) : void
      {
         var goInsane:Number = NaN;
         if(m_actionStarted)
         {
            switch(this.m_action)
            {
               case Pet.STATE_TICKLE:
               case Pet.STATE_ROLLOVER:
               case Pet.STATE_PLAYDEAD:
               case Pet.STATE_SHAKE:
                  this.m_animal.animalState = this.m_action;
                  break;
               default:
                  goInsane = Math.random();
                  if(goInsane < this.m_animal.getItem().insanePercent)
                  {
                     this.m_repeat = Math.floor(Math.random() * this.MAX_JUMPS);
                     this.jump();
                  }
                  else
                  {
                     this.dispOverlay();
                  }
                  this.m_animal.playRandomSound();
            }
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      private function jump() : void
      {
         var height:Number = NaN;
         var width:Number = NaN;
         height = this.m_animal.getDisplayObject().height;
         width = this.m_animal.getDisplayObject().width;
         TweenLite.to(this.m_animal.getDisplayObject(),0.4,{
            "scaleY":"-" + this.SCALE_JUMP,
            "y":"-" + 2 * this.m_jumpHeight / Math.max(height,width),
            "onComplete":function():void
            {
               if(m_repeat > 0)
               {
                  m_repeat = m_repeat - 1;
                  TweenLite.to(m_animal.getDisplayObject(),0.3,{
                     "scaleY":"" + SCALE_JUMP,
                     "y":"" + 2 * m_jumpHeight / Math.max(height,width),
                     "onComplete":jump
                  });
                  dispOverlay();
               }
               else
               {
                  TweenLite.to(m_animal.getDisplayObject(),0.3,{
                     "scaleY":"" + SCALE_JUMP,
                     "y":"" + 2 * m_jumpHeight / Math.max(height,width),
                     "ease":Bounce.easeOut,
                     "onComplete":dispOverlay
                  });
               }
            },
            "ease":Bounce.easeIn
         });
      }
      
      private function dispOverlay() : void
      {
         var pt:Point = null;
         var scale:Vector2 = new Vector2(this.m_animal.getActualDisplayObjectSize().x * this.S_OFFSET,this.m_animal.getActualDisplayObjectSize().y);
         if(this.m_animal.getDirection() % 2 == 1)
         {
            pt = new Point(this.m_animal.getScreenPosition().x,this.m_animal.getScreenPosition().y - 1);
            Global.ui.displayOverlaySWF(Global.getAssetURL(PETTING_URL),pt,scale,this.Y_OFFSET);
         }
         else
         {
            pt = new Point(this.m_animal.getScreenPosition().x - this.m_animal.getDisplayObject().width,this.m_animal.getScreenPosition().y - 1);
            Global.ui.displayOverlaySWF(Global.getAssetURL(PETTING_URL),pt,scale,this.Y_OFFSET);
         }
      }
   }
}

