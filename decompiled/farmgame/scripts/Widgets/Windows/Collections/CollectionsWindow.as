package Widgets.Windows.Collections
{
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Events.GenericPopupEvent;
   import Managers.CollectionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Collections.CollectionsRewardFrame;
   import Widgets.Frames.Collections.CollectionsSlotFrame;
   import Widgets.Frames.Collections.CollectionsThumbsFrame;
   import Widgets.Frames.Collections.LightningCollectionsSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CollectionsWindow extends FarmWindow
   {
      
      protected static const NUM_COLLECTABLES:int = 6;
      
      protected var m_howDoesThisWorkPopup:GenericPopup = null;
      
      protected var m_permanentSlotFrame:CollectionsSlotFrame = null;
      
      protected var m_lightningSlotFrame:LightningCollectionsSlotFrame = null;
      
      protected var m_PermanentButton:FarmAnimatedTextButton = null;
      
      protected var m_LightningButton:FarmAnimatedTextButton = null;
      
      private var m_collection:Collection;
      
      private var m_collectionThumbsFrame:CollectionsThumbsFrame;
      
      private var m_collectionRewardFrame:CollectionsRewardFrame;
      
      private var m_rewardFrame:ZwFrame;
      
      public function CollectionsWindow(collection:Collection = null)
      {
         this.m_collection = collection;
         super("assets/dialogs/FV_Collections2.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Collections")));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onClickHowDoesThisWork));
         this.m_collectionThumbsFrame = addWidget(new CollectionsThumbsFrame(m_window.catagorySlots_mc,this)) as CollectionsThumbsFrame;
         this.m_collectionRewardFrame = addWidget(new CollectionsRewardFrame(m_window.collectionPanel_mc,this,CollectionsManager.getInstance().getAllCollections()[0])) as CollectionsRewardFrame;
         if(this.m_collection == null)
         {
            this.m_collection = CollectionsManager.getInstance().getAllCollections()[0];
         }
         this.m_collectionRewardFrame.updateContents(this.m_collection);
         if(!Global.player.getSeenFlag("FirstTimeOpenCollectionsDialog"))
         {
            Global.player.setSeenFlag("FirstTimeOpenCollectionsDialog");
            this.onClickHowDoesThisWork();
         }
      }
      
      public function toggleEnabled(enable:Boolean) : void
      {
         this.enableInput = enable;
      }
      
      private function getCollectionData(displayMode:String) : Array
      {
         return null;
      }
      
      public function get defaultCollection() : Collection
      {
         return this.m_collection;
      }
      
      public function updateCollectionFrame(collection:Collection) : void
      {
         this.m_collectionThumbsFrame.refresh();
         this.m_collectionRewardFrame.updateContents(collection);
      }
      
      protected function addComingSoonSlots(data:Array) : void
      {
         var numNeeded:int = 0;
         var slotData:int = 0;
         var collection:Collection = null;
         if(data != null)
         {
            if(this.m_lightningSlotFrame)
            {
               numNeeded = CollectionsSlotFrame.NUM_SLOTS - data.length;
               for(slotData = 0; slotData < numNeeded; slotData++)
               {
                  collection = new Collection(new XML());
                  data.push(collection);
               }
            }
         }
      }
      
      protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         this.howDoesThisWork();
      }
      
      private function howDoesThisWork() : void
      {
         var howDoesThisWork:FarmDynamicDialog = FarmDynamicDialog.createDialog("CollectionsHowDoesThisWork",FarmDynamicDialog);
         howDoesThisWork.setup();
         howDoesThisWork.show();
      }
      
      protected function toggleButtonState(buttonState:String) : void
      {
         if(buttonState == Collection.TYPE_LIGHTNING)
         {
            this.m_LightningButton.setToggleState(ZwToggleState.SELECTED);
            this.m_PermanentButton.setToggleState(ZwToggleState.DESELECTED);
         }
         else
         {
            this.m_LightningButton.setToggleState(ZwToggleState.DESELECTED);
            this.m_PermanentButton.setToggleState(ZwToggleState.SELECTED);
         }
      }
      
      protected function onClickPermanentCollection(event:Event = null) : void
      {
         this.toggleButtonState(Collection.TYPE_PERMANENT);
         this.releaseOldWidgets();
         this.m_permanentSlotFrame = new CollectionsSlotFrame(m_window.collectionFrame_mc,this.getCollectionData(Collection.TYPE_PERMANENT),this);
         addWidget(this.m_permanentSlotFrame);
         this.m_permanentSlotFrame.setCollection(this.getCollectionData(Collection.TYPE_PERMANENT));
      }
      
      protected function onClickLightningCollection(event:Event = null) : void
      {
         this.toggleButtonState(Collection.TYPE_LIGHTNING);
         this.releaseOldWidgets();
         this.m_lightningSlotFrame = new LightningCollectionsSlotFrame(m_window.collectionFrame_mc,this.getCollectionData(Collection.TYPE_LIGHTNING),this);
         addWidget(this.m_lightningSlotFrame);
         this.m_lightningSlotFrame.setCollection(this.getCollectionData(Collection.TYPE_LIGHTNING));
      }
      
      protected function releaseOldWidgets() : void
      {
         if(this.m_permanentSlotFrame)
         {
            removeWidget(this.m_permanentSlotFrame);
            this.m_permanentSlotFrame = null;
         }
         if(this.m_lightningSlotFrame)
         {
            removeWidget(this.m_lightningSlotFrame);
            this.m_lightningSlotFrame = null;
         }
      }
      
      protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.visible = true;
         this.m_howDoesThisWorkPopup = null;
      }
      
      protected function closeHowDoesThisWorkPopup() : void
      {
         if(null != this.m_howDoesThisWorkPopup)
         {
            this.m_howDoesThisWorkPopup.close();
            this.m_howDoesThisWorkPopup = null;
         }
      }
      
      private function onAcceptCloseDialog(event:GenericPopupEvent) : void
      {
         close();
      }
   }
}

