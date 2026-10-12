package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class MarketOverlayWindow extends FarmWindow
   {
      
      public function MarketOverlayWindow(assetPath:String)
      {
         super(assetPath);
      }
      
      private static function onLegalClick(event:Event) : void
      {
         var url:String = ZLocUtils.t("Dialogs","bldg_hollybrightcityLegal");
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","HLights_Title")));
         }
         var descriptionText:String = Global.worldManager.currentWorldType !== "hlights" ? ZLocUtils.t("Dialogs","HLights_overlay") : ZLocUtils.t("Dialogs","HLights_overlay2");
         if(m_window.description_tf)
         {
            addWidget(new ZwTextField(m_window.description_tf,descriptionText));
         }
         if(m_window.legal_mc)
         {
            addWidget(new FarmAnimatedButton(m_window.legal_mc,onLegalClick));
         }
      }
   }
}

