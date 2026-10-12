package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.display.DisplayObject;
   
   public class BobBerryExpiryFrame extends ZwFrame
   {
      
      private var m_owner:BobBerryFarmWindow;
      
      private var m_featureName:String;
      
      private var m_berryexpiry:FarmTextField;
      
      private var m_berryexpirytext:FarmTextField;
      
      private var m_gotomarket:FarmAnimatedButton;
      
      private var m_berrycount:FarmTextField;
      
      public function BobBerryExpiryFrame(owner:BobBerryFarmWindow, element:DisplayObject, featureName:String)
      {
         this.m_owner = owner;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("title2_tf"))
         {
            this.m_berryexpiry = addWidget(new FarmTextField(m_element.title2_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_berryexpire_title")),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("buymore_tf"))
         {
            this.m_berryexpirytext = addWidget(new FarmTextField(m_element.buymore_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_berryexpire_text")),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("gotomarket_bt"))
         {
            this.m_gotomarket = addWidget(new FarmAnimatedButton(m_element.gotomarket_bt,this.m_owner.openBobsMarket),true) as FarmAnimatedButton;
         }
         if(m_element.hasOwnProperty("fullcount_tf"))
         {
            this.m_berrycount = addWidget(new FarmTextField(m_element.fullcount_tf,BobBerryManager.getInstance(this.m_featureName).getCurrentCurrencyCount() as String),true) as FarmTextField;
         }
      }
      
      override public function release() : void
      {
         this.m_owner = null;
         this.m_berryexpiry = null;
         this.m_berryexpirytext = null;
         this.m_gotomarket = null;
         this.m_berrycount = null;
         super.release();
      }
   }
}

