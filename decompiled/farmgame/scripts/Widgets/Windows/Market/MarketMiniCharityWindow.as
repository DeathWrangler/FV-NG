package Widgets.Windows.Market
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class MarketMiniCharityWindow extends MarketMiniWindow
   {
      
      private var m_wcn_mc:MovieClip = null;
      
      private var m_header_tf:ZwTextField;
      
      private var m_learnMore_tf:ZwTextField;
      
      private var m_learnMore_bt:FarmAnimatedButton;
      
      private var m_legal_tf:ZwTextField;
      
      private var m_featurename:String = "WCNMarketURL_";
      
      public function MarketMiniCharityWindow(itemNames:Array, featureName:String, hideCloseButton:Boolean = false, checkVisible:Boolean = false)
      {
         super(itemNames,hideCloseButton,checkVisible);
         m_viewSource = featureName;
         this.m_featurename = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         this.initCharityPanel();
         super.postLoadComplete();
      }
      
      override protected function refreshItems() : void
      {
         if(this.m_wcn_mc != null)
         {
            this.m_wcn_mc.visible = true;
         }
         super.refreshItems();
      }
      
      private function initCharityPanel() : void
      {
         if(Boolean(m_window) && Boolean(m_window.wcn_mc2))
         {
            this.m_wcn_mc = m_window.wcn_mc2;
            if(this.m_wcn_mc)
            {
               this.m_header_tf = addWidget(new ZwTextField(this.m_wcn_mc.header_tf,ZLocUtils.t("Dialogs","WCNMarket_Header"))) as ZwTextField;
               this.m_learnMore_tf = addWidget(new ZwTextField(this.m_wcn_mc.learnMore_tf,ZLocUtils.t("Dialogs","WCNMarket_LearnMore"))) as ZwTextField;
               this.m_learnMore_bt = addWidget(new FarmAnimatedTextButton(this.m_wcn_mc.learnMore_bt,ZLocUtils.t("Dialogs","WCNMarket_LearnMoreBtn"),this.onClickLearnMore,true)) as FarmAnimatedTextButton;
               this.m_legal_tf = addWidget(new ZwTextField(this.m_wcn_mc.legal_mc.generic_tf,ZLocUtils.t("Dialogs","WCNMarket_Legal"))) as ZwTextField;
            }
         }
      }
      
      private function onClickLearnMore(e:MouseEvent) : void
      {
         var url:String = ZLocUtils.t("Dialogs",this.m_featurename + "Legal");
         navigateToURL(new URLRequest(url),"_blank");
      }
   }
}

