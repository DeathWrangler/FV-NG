package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class BrandedPromoHelpAndShareWindow extends BrandedPromoWindow
   {
      
      private static const SHARE_SCENE_FLAG_NAME:String = "SEENFLAG_seenShareForBrandedFarm_";
      
      protected var m_shareCallback:Function;
      
      private var m_shareButtonDisplayObject:FarmButton;
      
      public function BrandedPromoHelpAndShareWindow(promoName:String, closeCallback:Function, shareCallback:Function, assetPath:String = "")
      {
         super(promoName,closeCallback,assetPath);
         this.m_shareCallback = shareCallback;
         m_localizeTextPrefix = "PromoFarmHelp";
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         var textPrefix:String = getLocalizeTextPrefix() + "_" + m_promoName + "_";
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",textPrefix + "title")));
         addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",textPrefix + "body"),true));
         addWidget(new ZwTextField(m_window.body1_tf,ZLocUtils.t("Dialogs",textPrefix + "body1"),true));
      }
      
      override protected function setupButtons() : void
      {
         addWidget(new FarmAnimatedTextButton(m_window.stayHere_bt,ZLocUtils.t("Dialogs","PromoFarmHelpButton"),onAccept));
         this.m_shareButtonDisplayObject = addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","ShareTheNews"),this.onShare)) as FarmButton;
         if(Global.player.getSeenFlag(SHARE_SCENE_FLAG_NAME + m_promoName))
         {
            this.m_shareButtonDisplayObject.enabled = false;
            this.m_shareButtonDisplayObject.applyGrayOut = true;
         }
      }
      
      protected function onShare(event:Event) : void
      {
         if(this.m_shareCallback != null && this.m_shareButtonDisplayObject.enabled)
         {
            this.m_shareCallback(true);
            this.m_shareButtonDisplayObject.enabled = false;
            this.m_shareButtonDisplayObject.applyGrayOut = true;
            Global.player.setSeenFlag(SHARE_SCENE_FLAG_NAME + m_promoName,true);
         }
      }
   }
}

