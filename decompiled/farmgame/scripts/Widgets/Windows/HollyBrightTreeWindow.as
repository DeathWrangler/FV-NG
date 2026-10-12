package Widgets.Windows
{
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class HollyBrightTreeWindow extends GivingBuildingWindow
   {
      
      public function HollyBrightTreeWindow(building:StorageBuilding)
      {
         super(building);
      }
      
      override protected function postLoadComplete() : void
      {
         var charityFrame:ZwFrame = null;
         super.postLoadComplete();
         addWidget(m_currencyFrame = new ZwFrame(m_window.sparklelights_mc));
         m_currencyFrame.addWidget(m_makeButton = new FarmAnimatedTextButton(m_window.sparklelights_mc.make_bt,ZLocUtils.t("Dialogs",m_locPrefix + "MakeCurrency"),onMakeCurrency));
         var partName:String = this.getPartName();
         m_currencyFrame.addWidget(m_currencyCountTextField = new ZwTextField(m_window.sparklelights_mc.count_tf,Global.player.getGiftCountForItem(partName).toString()));
         m_currencyFrame.addWidget(new ZwTextField(m_window.sparklelights_mc.generic_tf,ZLocUtils.t("Dialogs",m_locPrefix + "GenericCurrency")));
         m_currencyFrame.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",m_locPrefix + "CurrencyTooltip")));
         addWidget(charityFrame = new ZwFrame(m_window.charity_mc));
         charityFrame.addWidget(new ZwTextField(m_window.charity_mc.generic_tf,ZLocUtils.t("Dialogs",m_locPrefix + "GenericCharity")));
         charityFrame.addWidget(new FarmAnimatedTextButton(m_window.charity_mc.link_mc,ZLocUtils.t("Dialogs",m_locPrefix + "CharityMore"),this.onLinkClicked));
         addWidget(new FarmAnimatedTextButton(m_window.link_mc,ZLocUtils.t("Dialogs",m_locPrefix + "LinkText"),this.onLinkClicked));
      }
      
      private function onLinkClicked(event:Event) : void
      {
         var url:String = ZLocUtils.t("Dialogs",m_locPrefix + "ClickHereUrl");
         navigateToURL(new URLRequest(url),"_blank");
      }
   }
}

