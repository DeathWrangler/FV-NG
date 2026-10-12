package Widgets.Slots
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.WanderingPirateManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class WanderingPirateRewardItemsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      protected var m_owner:DisplayObject;
      
      private var m_itemTypeText:ZwTextField;
      
      protected var m_data:Object;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_itemCount:FarmTextField;
      
      private var m_keyBoxNumber:int;
      
      private var m_getKeyBoxNumber:Function;
      
      private var m_itemName:FarmTextField;
      
      public function WanderingPirateRewardItemsSlot(element:DisplayObject, owner:DisplayObject, callback:Function)
      {
         super(element);
         this.m_owner = owner;
         this.m_getKeyBoxNumber = callback;
         if(m_element.hasOwnProperty("itemType_txt"))
         {
            this.m_itemTypeText = new ZwTextField(m_element.itemType_txt,"");
            addWidget(this.m_itemTypeText);
         }
         if(m_element.hasOwnProperty("itemCount_tf"))
         {
            this.m_itemCount = new FarmTextField(m_element.itemCount_tf,"");
            addWidget(this.m_itemCount,true);
            this.m_itemCount.visible = true;
         }
         if(m_element.hasOwnProperty("itemName_tf"))
         {
            this.m_itemName = new FarmTextField(m_element.itemName_tf,"");
            this.m_itemName.visible = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         var itemName:String = data["rewardName"];
         var itemRarity:String = data["rewardType"];
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.refreshRewardCount();
         if(Boolean(this.m_itemName) && Boolean(farmItem))
         {
            this.m_itemName.text = farmItem.friendlyTitle;
         }
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconPreview)
         {
            this.m_iconPreview.clearDimensions();
            removeWidget(this.m_iconPreview);
            this.m_iconPreview = null;
         }
         if(m_element.hasOwnProperty("objectPreview_mc") && farmItem.getImageByName("frt_idle") != null)
         {
            this.m_objectPreviewFrame = new ObjectPreviewFrame(m_element.objectPreview_mc,farmItem,null,null,[100],Animal.STATE_FRONT_IDLE);
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_objectPreviewFrame,true);
         }
         else if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_iconPreview = new FarmIcon(m_element.icon_mc,farmItem.getImageByName(FarmItem.ICON_FEED));
            this.m_iconPreview.setIconSize(ICON_SIZE,ICON_SIZE);
            addWidget(this.m_iconPreview,true);
         }
         if(this.m_itemTypeText)
         {
            this.m_itemTypeText.visible = true;
            this.m_itemTypeText.text = ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_" + itemRarity);
         }
      }
      
      override public function release() : void
      {
         if(this.m_iconPreview)
         {
            this.m_iconPreview = null;
         }
         if(this.m_objectPreviewFrame)
         {
            this.m_objectPreviewFrame = null;
         }
         super.release();
      }
      
      public function refreshRewardCount() : void
      {
         var getCountData:Object = null;
         var itemName:String = this.m_data["rewardName"];
         var itemRarity:String = this.m_data["rewardType"];
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         getCountData = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).getRewardCount(this.m_getKeyBoxNumber());
         if(this.m_itemCount)
         {
            if(Boolean(getCountData) && Boolean(getCountData[farmItem.code]))
            {
               this.m_itemCount.text = "x" + getCountData[farmItem.code];
            }
            else
            {
               this.m_itemCount.text = "x0";
            }
            this.m_itemCount.visible = true;
         }
      }
   }
}

