package Display
{
   import Classes.buffs.BBushel;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Widgets.Icons.FarmIcon;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CropBoostIcon extends FarmGameSprite
   {
      
      protected var m_loader:Loader = null;
      
      private var m_frameClip:MovieClip;
      
      private var m_cropBuffIcon:FarmIcon;
      
      private var m_currentCropBuffType:int;
      
      private var m_currentCropImageUrl:String;
      
      private var m_loaded:Boolean;
      
      private var m_hasBuff:Boolean = false;
      
      public function CropBoostIcon()
      {
         super();
         this.buttonMode = false;
         this.useHandCursor = false;
         Utilities.toggleInputOnlyChildren(this,false);
         this.scaleX = this.scaleY = 0.85;
         this.normalScale = 0.85;
         this.rollOverScale = 1;
         this.visible = false;
         this.m_loader = LoadingManager.load(Global.getAssetURL("assets/hud/FV_CropBoostIcon.swf"),this.onIconFrameLoaded);
      }
      
      public function get hasBuff() : Boolean
      {
         return this.m_hasBuff;
      }
      
      protected function onIconFrameLoaded(event:Event) : void
      {
         this.m_frameClip = this.m_loader.content as MovieClip;
         if(this.m_frameClip != null)
         {
            this.addChild(this.m_frameClip);
            this.m_loaded = true;
            this.m_cropBuffIcon = new FarmIcon(this.m_frameClip.icon_mc,"");
            this.refresh();
         }
      }
      
      private function setTypeIconVisible(cropBuffType:int) : void
      {
         this.m_frameClip.lockIcon_mc.visible = cropBuffType == BBushel.TYPE_LICENSE;
         this.m_frameClip.masteryIcon_mc.visible = cropBuffType == BBushel.TYPE_MASTERY;
         this.m_frameClip.xpIcon_mc.visible = cropBuffType == BBushel.TYPE_CROPEXP;
      }
      
      private function refresh() : void
      {
         if(this.m_loaded)
         {
            if(this.m_hasBuff)
            {
               this.visible = !Global.worldManager.isVisiting();
               this.setTypeIconVisible(this.m_currentCropBuffType);
               if(this.m_cropBuffIcon.iconUrl != this.m_currentCropImageUrl)
               {
                  this.m_cropBuffIcon.loadIcon(this.m_currentCropImageUrl);
                  this.m_cropBuffIcon.setIconSize(50,50);
               }
            }
            else
            {
               this.visible = false;
            }
         }
      }
      
      public function setBuffDetails(newIconUrl:String, cropBuffType:int, toolTip:String) : void
      {
         this.m_hasBuff = true;
         this.m_currentCropImageUrl = newIconUrl;
         this.m_currentCropBuffType = cropBuffType;
         this.toolTip = toolTip;
         this.refresh();
      }
      
      public function hideBuffDetails() : void
      {
         this.m_hasBuff = true;
         this.refresh();
      }
   }
}

