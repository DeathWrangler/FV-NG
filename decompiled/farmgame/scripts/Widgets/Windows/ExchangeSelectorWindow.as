package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.DynamicObjectEvent;
   import Managers.ExchangeManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Slots.ExchangeSelectorSlot;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ExchangeSelectorWindow extends FarmWindow
   {
      
      private static var m_manager:ExchangeManager = null;
      
      private var m_featureName:String = "";
      
      private var m_state:String = "";
      
      private var m_searchedItems:Array = null;
      
      public function ExchangeSelectorWindow(featureName:String, state:String)
      {
         this.m_featureName = featureName;
         this.m_state = state;
         m_manager = ExchangeManager.getInstance();
         super("assets/dialogs/Fv_bushelswap_addbushel.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var addState:Boolean = this.m_state == ExchangeManager.ADD_STATE;
         var selectState:Boolean = this.m_state == ExchangeManager.SELECT_STATE;
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorTitle_" + this.m_state)));
         }
         if(m_window.sub_tf != null)
         {
            addWidget(new ZwTextField(m_window.sub_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorDescription_" + this.m_state)));
         }
         if(m_window.total_tf != null)
         {
            addWidget(new ZwTextField(m_window.total_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorCount_" + this.m_state,{"quantity":m_manager.getTradeInNumberNeeded(this.m_featureName)})),addState);
         }
         if(m_window.searchBar_mc != null)
         {
            addWidget(new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate));
         }
         if(m_window.save_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.save_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorSave"),this.saveCallback),addState);
         }
         if(m_window.cancel_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorCancel"),this.cancelCallback),addState);
         }
         if(m_window.selectClose_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.selectClose_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorClose"),this.closeSelectCallback),selectState);
         }
         this.m_searchedItems = m_manager.getExchangeItems(this.m_featureName,this.m_state);
         var emptyVis:Boolean = false;
         if(this.m_searchedItems == null || this.m_searchedItems.length == 0)
         {
            emptyVis = true;
         }
         addWidget(new GenericSlotContainerFrame(m_window.bushelSlotFrame_mc,ExchangeSelectorSlot,this.m_searchedItems,this));
         if(m_window.empty_tf != null)
         {
            addWidget(new ZwTextField(m_window.empty_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorEmpty")),emptyVis);
         }
      }
      
      public function onSearchUpdate(searchString:String) : void
      {
         var eachItem:FarmItem = null;
         var itemName:String = null;
         var newItems:Array = new Array();
         var items:Array = m_manager.getExchangeItems(this.m_featureName,this.m_state);
         if(searchString != "")
         {
            for each(eachItem in items)
            {
               itemName = eachItem.searchTitle;
               if(itemName.search(searchString) != -1)
               {
                  newItems.push(eachItem);
               }
            }
         }
         else
         {
            newItems = items;
         }
         this.m_searchedItems = newItems;
         this.refreshWindow();
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      public function getState() : String
      {
         return this.m_state;
      }
      
      override public function refreshWindow() : void
      {
         var slotFrame:GenericSlotContainerFrame = getWidget(m_window.bushelSlotFrame_mc) as GenericSlotContainerFrame;
         if(slotFrame != null)
         {
            slotFrame.setData(this.m_searchedItems);
         }
         this.updateTotalTally();
      }
      
      private function saveCallback(event:MouseEvent) : void
      {
         m_manager.confirmInputs(this.m_featureName);
         close();
      }
      
      private function closeSelectCallback(event:MouseEvent) : void
      {
         m_manager.dispatchEvent(new DynamicObjectEvent(ExchangeManager.UPDATE_EVENT));
         close();
      }
      
      private function cancelCallback(event:MouseEvent) : void
      {
         m_manager.resetInputItems(this.m_featureName);
         this.refreshWindow();
      }
      
      override protected function onClose(event:Event) : void
      {
         m_manager.revertInputs(this.m_featureName);
         close();
      }
      
      public function updateTotalTally() : void
      {
         var totalTally:ZwTextField = null;
         var numNeeded:int = 0;
         if(m_window.total_tf != null)
         {
            totalTally = getWidget(m_window.total_tf) as ZwTextField;
            numNeeded = m_manager.getTradeInNumberNeeded(this.m_featureName);
            if(numNeeded > 0)
            {
               totalTally.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorCount_" + this.m_state,{"quantity":numNeeded});
            }
            else
            {
               totalTally.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectorCountReady_" + this.m_state);
            }
         }
      }
   }
}

