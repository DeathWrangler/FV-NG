package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.FarmGameObject;
   import Classes.MapResource;
   import Managers.CrossPromoManager;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class AMMultiResourceAction extends AMActionState
   {
      
      protected static const STATUS_ENERGY_SOURCE_FUEL:String = "fuel";
      
      protected static const STATUS_ENERGY_SOURCE_FREE_FUEL:String = "freefuel";
      
      protected static const RESOURCE_FADE_ALPHA:Number = 0.6;
      
      protected var m_resources:Array = [];
      
      protected var m_centerPos:Point;
      
      public function AMMultiResourceAction(avatar:FarmAvatar, resources:Array, centerPos:Point)
      {
         super(avatar,null);
         this.m_resources = resources;
         this.m_centerPos = centerPos;
      }
      
      override public function getNumActions() : int
      {
         return this.m_resources.length;
      }
      
      override public function added() : void
      {
         super.added();
         this.fadeAndLockResources(true);
      }
      
      override public function removed() : void
      {
         super.removed();
         this.fadeAndLockResources(false);
         this.show();
      }
      
      protected function fadeAndLockResources(onOff:Boolean, noFade:Boolean = false) : void
      {
         var resource:MapResource = null;
         var fadeAlpha:Number = 1;
         if(onOff && !noFade)
         {
            fadeAlpha = RESOURCE_FADE_ALPHA;
         }
         for each(resource in this.m_resources)
         {
            resource.setAlpha(fadeAlpha);
            if(onOff)
            {
               resource.lock();
            }
            else
            {
               resource.unlock();
            }
         }
      }
      
      override public function enter() : void
      {
         super.enter();
         this.hide();
      }
      
      override public function reenter() : void
      {
         super.reenter();
         this.hide();
      }
      
      protected function hide() : void
      {
         TweenLite.to(m_avatar,0.25,{"alpha":0});
      }
      
      protected function show() : void
      {
         TweenLite.to(m_avatar,0.25,{"alpha":1});
      }
      
      override protected function getActionDistance() : Number
      {
         return -1;
      }
      
      protected function notifyOutOfFuel() : void
      {
         var crossPromoManager:CrossPromoManager = null;
         if(!Global.player.hasEnergy())
         {
            crossPromoManager = CrossPromoManager.getInstance();
            crossPromoManager.notifyBeginOutBoundPromo("use_x_fuel");
         }
      }
      
      protected function notifyFuelUse(energy:int) : void
      {
         var crossPromoManager:CrossPromoManager = null;
         if(energy > 0)
         {
            crossPromoManager = CrossPromoManager.getInstance();
            crossPromoManager.notifyFuelUse(energy);
         }
      }
      
      protected function performAction(energySource:int, resources:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, sendTransaction:Boolean = true) : int
      {
         return 0;
      }
   }
}

