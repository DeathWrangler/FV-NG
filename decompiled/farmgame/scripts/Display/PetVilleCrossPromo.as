package Display
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PetVilleCrossPromo extends Dialog
   {
      
      private var m_iconLoader:Loader;
      
      private var m_accept:GenericButton;
      
      private var m_cancel:GenericButton;
      
      public function PetVilleCrossPromo(modal:Boolean = true)
      {
         m_dialogAsset = "assets/dialogs/FV_Wandering_Animal.swf";
         super(modal);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.callOutBox_mc.close_bt.visible = false;
         m_window.callOutBox_mc.callOut_tf.text = ZLocUtils.t("Dialogs","PetVilleCrossPromo");
         this.m_accept = new GenericButton(m_window.callOutBox_mc.help_bt,this.onAcceptClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","PetVilleCrossPromoAcceptButton");
         this.m_cancel = new GenericButton(m_window.callOutBox_mc.cancel_bt,this.onCloseClick);
         this.m_cancel.text = ZLocUtils.t("FarmGame","Cancel");
         this.m_iconLoader = LoadingManager.load(Global.getAssetURL("assets/hud/clueicon_100x100.png"),this.onIconLoaded);
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var iconMc:MovieClip = m_window.callOutBox_mc.icon_mc;
         iconMc.scaleX = iconMc.scaleY = 1;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = this.m_iconLoader.content;
         newIcon.x = -newIcon.width / 2;
         newIcon.y = -newIcon.height / 2;
         iconMc.addChild(newIcon);
      }
      
      private function onAcceptClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         FarmStatsManager.count("PetVilleCrossPromo","click_accept");
         close();
         GlobalEngine.socialNetwork.redirect("http://apps.facebook.com/petvillegame/tracks.php?src=farmxpromo&aff=farmpets",null,"_blank",false);
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         event.stopPropagation();
         FarmStatsManager.count("PetVilleCrossPromo","click_notnow");
         close();
      }
   }
}

