package Widgets.Frames.Market
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class MarketCharityBannerFrame extends ZwFrame
   {
      
      private static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private static const LEARN_MORE_LINK:String = "http://zynga.org/campaigns/farmville-charity-le-items";
      
      public function MarketCharityBannerFrame(element:MovieClip)
      {
         super(element);
         if(m_element.hasOwnProperty("bannerTitle_txt"))
         {
            addWidget(new FarmTextField(m_element.bannerTitle_txt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"leForCharity_titleTxt"))) as FarmTextField;
         }
         if(m_element.hasOwnProperty("bannersub_txt"))
         {
            addWidget(new FarmTextField(m_element.bannersub_txt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"leForCharity_bodyTxt"))) as FarmTextField;
         }
         if(m_element.hasOwnProperty("bannerLink_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_element.bannerLink_mc,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"leForCharity_learnMore"),this.onLearnMoreClick)) as FarmAnimatedTextButton;
         }
      }
      
      private function onLearnMoreClick(event:Event) : void
      {
         try
         {
            navigateToURL(new URLRequest(LEARN_MORE_LINK),"_blank");
         }
         catch(e:Error)
         {
            FarmGameUtil.reportClientLog("Navigate to charity url failed : MarketCharityBannerFrame.onLearnMoreClick : " + e.message);
         }
      }
   }
}

