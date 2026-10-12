package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BringBackWinterSFBuySlot extends ZwFrame
   {
      
      private var m_sfPkg:String;
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_buySf:FarmAnimatedCashButton;
      
      public function BringBackWinterSFBuySlot(element:DisplayObject, featureName:String, sfPkg:String)
      {
         super(element);
         this.m_sfPkg = sfPkg;
         this.m_featureName = featureName;
         var sfPkgItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(sfPkg);
         if(element.hasOwnProperty("buySnowflake_mc"))
         {
            addWidget(new ZwWidget(element["buySnowflake_mc"]),true);
         }
         if(element.hasOwnProperty("buyRandom_bt"))
         {
            addWidget(this.m_buySf = new FarmAnimatedCashButton(element["buyRandom_bt"],"",sfPkgItem.cash.toString(),this.onBuyClick,false,false,true),true);
            this.m_buySf.text = sfPkg == BringBackWinterManager.SF_BUNDLE_PKG ? ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageBuyAll") : ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Buy");
         }
      }
      
      private function onBuyClick(event:Event) : void
      {
         BringBackWinterManager.getInstance(this.m_featureName).buySf(this.m_sfPkg);
      }
   }
}

