package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BirthdayFreeGiftsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Frames.BirthdayFreeGiftsSlotContainerFrame;
   import Widgets.TextFields.FarmTextField;
   
   public class BirthdayFreeGiftsWindow extends FarmWindow
   {
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private var m_featureName:String = null;
      
      private var m_manager:BirthdayFreeGiftsManager;
      
      private var m_slots:BirthdayFreeGiftsSlotContainerFrame;
      
      private var m_startDateArray:Array;
      
      public function BirthdayFreeGiftsWindow(featureName:String, assetUrl:String = "assets/dialogs/FV_farm5thbday.swf")
      {
         super(assetUrl);
         this.m_featureName = featureName;
         this.m_manager = BirthdayFreeGiftsManager.getInstance();
         this.m_startDateArray = BirthdayFreeGiftsManager.getInstance().getStartDate();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(this.m_manager)
         {
            this.m_manager.setFeatureLastShown();
         }
         if(m_window)
         {
            FarmStatsManager.count("dialog","birthdayFG2014_window","view");
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_title"))) as FarmTextField;
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_subtitle"))) as FarmTextField;
            if(m_window.slots_mc)
            {
               this.m_slots = new BirthdayFreeGiftsSlotContainerFrame(m_window.slots_mc,this);
               if(this.m_slots)
               {
                  addWidget(this.m_slots);
                  this.refresh();
               }
            }
         }
      }
      
      public function refresh() : void
      {
         var slotItems:Array = null;
         var gift:Object = null;
         var gifts:Array = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,BirthdayFreeGiftsManager.GIFTS_FEATURE_OPTION) as Array;
         if(Boolean(gifts) && gifts.length > 0)
         {
            if(this.m_slots)
            {
               slotItems = [];
               for each(gift in gifts)
               {
                  this.setState(slotItems,gift[BirthdayFreeGiftsManager.ITEM_NAME],gift[BirthdayFreeGiftsManager.ITEM_STATE]);
               }
               if(slotItems[gifts.length - 1][BirthdayFreeGiftsManager.ITEM_STATE] == BirthdayFreeGiftsManager.CLAIMED_STATE)
               {
                  this.setState(slotItems,BirthdayFreeGiftsManager.DEFAULT_NAME,BirthdayFreeGiftsManager.TIMER_STATE);
               }
               while(slotItems.length < BirthdayFreeGiftsManager.NUMBER_OF_DAYS_GIFTS_AWARDED)
               {
                  this.setState(slotItems,BirthdayFreeGiftsManager.DEFAULT_NAME,BirthdayFreeGiftsManager.DEFAULT_STATE);
               }
               this.m_slots.items = slotItems;
            }
         }
      }
      
      private function setState(slotItems:Array, itemName:String, itemState:String) : void
      {
         slotItems.push({
            "itemName":itemName,
            "itemState":itemState,
            "dayNumber":slotItems.length + 1
         });
      }
      
      override protected function release() : void
      {
         this.m_slots = null;
         this.m_manager = null;
         this.m_featureName = null;
         super.release();
      }
   }
}

