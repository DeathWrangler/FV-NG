package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BHarvestHelper;
   import Classes.util.ZLocUtils;
   import Managers.TargetedRewardsManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class TargetedRewardsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 80;
      
      private static const SMALL_ICON_SIZE:int = 60;
      
      private static const TOOLTIP_KEY:String = "TRP_tooltip_";
      
      protected var m_owner:DisplayObject;
      
      protected var m_data:Object;
      
      protected var m_itemNameText:ZwTextField;
      
      protected var m_itemAmountText:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      private var m_isFirstDay:Boolean;
      
      public function TargetedRewardsSlot(element:DisplayObject, owner:DisplayObject, isFirstDay:Boolean)
      {
         super(element);
         this.m_owner = owner;
         this.m_isFirstDay = isFirstDay;
         if(m_element.hasOwnProperty("itemTitle_tf"))
         {
            this.m_itemNameText = new ZwTextField(m_element.itemTitle_tf);
            addWidget(this.m_itemNameText);
         }
         if(m_element.hasOwnProperty("itemAmount_tf"))
         {
            this.m_itemAmountText = new ZwTextField(m_element.itemAmount_tf,"");
            addWidget(this.m_itemAmountText);
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_icon = new FarmIcon(m_element.icon_mc));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var toolTipText:String = null;
         var tooltipKey:String = null;
         var size:int = 0;
         super.populate(data);
         this.m_data = data;
         var itemName:String = data[TargetedRewardsManager.ITEM_NAME_KEY];
         var itemAmount:String = data[TargetedRewardsManager.ITEM_AMOUNT_KEY];
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var index:int = int(data["index"]);
         if(item != null)
         {
            if(this.m_itemNameText)
            {
               this.m_itemNameText.text = ZLocUtils.tk_pk_asTitle(item.friendlyName);
               this.m_itemNameText.visible = true;
            }
            if(Boolean(this.m_itemAmountText) && item.name != BHarvestHelper.BUFF_ITEM_NAME)
            {
               this.m_itemAmountText.text = "x" + itemAmount;
               this.m_itemAmountText.visible = true;
            }
            toolTipText = "";
            tooltipKey = TOOLTIP_KEY + itemName;
            if(ZLocUtils.hasString("Dialogs",tooltipKey))
            {
               toolTipText = ZLocUtils.t("Dialogs",tooltipKey);
            }
            else
            {
               toolTipText = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            }
            this.attachTooltip(new FarmTextTooltip(toolTipText));
            if(this.m_icon)
            {
               this.m_icon.loadIcon(item.iconUrl);
               size = (index == 2 || index == 3) && this.m_isFirstDay ? SMALL_ICON_SIZE : ICON_SIZE;
               this.m_icon.setIconSize(size,size);
               this.m_icon.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_itemAmountText = null;
         this.m_itemNameText = null;
         super.release();
      }
   }
}

