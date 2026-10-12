package Display
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Widgets.Icons.FarmIcon;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class SuperAvatarIcon extends FarmGameSprite
   {
      
      private const INVALID_RESOURCE_ACTION:int = -1;
      
      private const ASSET_URL:String = "assets/dialogs/FV_BuffIcon.swf";
      
      protected var m_loader:Loader = null;
      
      private var m_frameClip:MovieClip;
      
      private var m_superAvatarIcon:FarmIcon;
      
      private var m_resourceAction:int = -1;
      
      private var m_iconUrl:String = null;
      
      private var m_loaded:Boolean;
      
      public function SuperAvatarIcon(assetUrl:String = "assets/dialogs/FV_BuffIcon.swf")
      {
         super();
         this.buttonMode = false;
         this.useHandCursor = false;
         Utilities.toggleInputOnlyChildren(this,false);
         this.scaleX = this.scaleY = 1;
         this.normalScale = 1;
         this.rollOverScale = 1;
         this.visible = false;
         this.m_loader = LoadingManager.load(Global.getAssetURL(assetUrl),this.onIconFrameLoaded);
      }
      
      protected function onIconFrameLoaded(event:Event) : void
      {
         this.m_frameClip = this.m_loader.content as MovieClip;
         if(this.m_frameClip != null)
         {
            this.addChild(this.m_frameClip);
            this.m_loaded = true;
            this.m_superAvatarIcon = new FarmIcon(this.m_frameClip.icon_mc,"");
            this.refresh();
         }
      }
      
      private function refresh() : void
      {
         if(this.m_loaded)
         {
            if(this.m_resourceAction != this.INVALID_RESOURCE_ACTION)
            {
               visible = !Global.worldManager.isVisiting();
               if(this.m_superAvatarIcon.iconUrl != this.m_iconUrl)
               {
                  this.m_superAvatarIcon.loadIcon(this.m_iconUrl);
                  this.m_superAvatarIcon.setIconSize(50,50);
               }
            }
            else
            {
               visible = false;
            }
         }
      }
      
      public function showIcon(resourceAction:int) : void
      {
         this.m_resourceAction = resourceAction;
         this.m_iconUrl = Global.getAssetURL(Global.farmGameSettingsManager.getString("superAvatarIcon" + resourceAction));
         toolTip = ZLocUtils.t("FarmGame","SuperAvatarTooltip_" + resourceAction);
         this.setCount(Global.player.getNumSuperAvatarActions(resourceAction));
         this.refresh();
      }
      
      public function hideIcon() : void
      {
         this.m_resourceAction = this.INVALID_RESOURCE_ACTION;
         this.refresh();
      }
      
      public function setCount(count:int) : void
      {
         if(this.m_frameClip != null)
         {
            this.m_frameClip.buffCounter_mc.generic_tf.text = count.toString();
         }
      }
   }
}

