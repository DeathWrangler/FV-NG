package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Frames.HalloweenUSARedeemFrame;
   
   public class HalloweenUSARedeemWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private var m_slots:HalloweenUSARedeemFrame;
      
      private var m_featureName:String = null;
      
      private var m_category:String;
      
      public function HalloweenUSARedeemWindow(featureName:String, category:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         this.m_category = category;
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RdeemMarketWindow_Title");
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemMarketWindow_BodyText");
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_slots = new HalloweenUSARedeemFrame(m_window[this.SLOTS_MC],this.m_featureName,this);
            this.m_slots.visible = true;
            addWidget(this.m_slots,true);
         }
      }
      
      override public function close() : void
      {
         FarmStatsManager.count("RockPaperShivers","Market_UI","close",this.m_category);
         super.close();
      }
      
      public function get category() : String
      {
         return this.m_category;
      }
   }
}

