package Widgets.Slots.Collections
{
   import Classes.Collections.Collectible;
   import Classes.util.ZLocUtils;
   import Managers.CollectionsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Collections.CollectionsWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.filters.ColorMatrixFilter;
   
   public class CollectibleSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_parentWindow:CollectionsWindow;
      
      private var m_collectible:Collectible;
      
      private var m_icon:FarmIcon;
      
      private var m_collectibleCount:ZwTextField;
      
      private var m_collectibleBackground:ZwBaseWidget;
      
      private var m_emptyBackground:ZwBaseWidget;
      
      private var m_rarity:ZwTextField;
      
      private var m_checkmark:ZwBaseWidget;
      
      private var m_ask:FarmAnimatedButton;
      
      private var m_askButtonText:ZwTextField;
      
      private var m_iconTooltip:FarmTextTooltip;
      
      public function CollectibleSlot(element:DisplayObject, parentWindow:CollectionsWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_collectibleCount = addWidget(new ZwTextField(m_element.collectibleCount_tf)) as ZwTextField;
         this.m_rarity = addWidget(new ZwTextField(m_element.rarity_tf)) as ZwTextField;
         this.m_checkmark = addWidget(new ZwBaseWidget(m_element.checkmark_mc)) as ZwBaseWidget;
         this.m_collectibleBackground = addWidget(new ZwBaseWidget(m_element.collectionFill_mc)) as ZwBaseWidget;
         this.m_emptyBackground = addWidget(new ZwBaseWidget(m_element.collectionNull_mc)) as ZwBaseWidget;
         this.m_ask = addWidget(new FarmAnimatedButton(m_element.ask_mc,this.askForCollectibleClick)) as FarmAnimatedButton;
         this.m_askButtonText = addWidget(new ZwTextField(m_element.ask_mc.ask_bt.generic_tf)) as ZwTextField;
         this.m_askButtonText.text = ZLocUtils.t("Dialogs","GenericAsk");
         this.m_icon = new FarmIcon(m_element.icon_mc);
         this.m_iconTooltip = new FarmTextTooltip();
         this.m_icon.attachTooltip(this.m_iconTooltip);
      }
      
      private function askForCollectibleClick(event:Event) : void
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r2FlowCalled","CollectibleSlot_askForCollectibleClick");
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refresh(data);
      }
      
      public function refresh(data:Object) : void
      {
         this.m_collectible = data as Collectible;
         this.m_collectibleCount.text = this.m_collectible.numOwned + "/" + this.m_collectible.numNeeded;
         this.m_rarity.text = ZLocUtils.t_pk(this.m_collectible.rarityStringFriendlyName);
         if(this.m_collectible != null)
         {
            this.m_icon.loadIcon(this.m_collectible.item.icon);
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_iconTooltip.setText(ZLocUtils.tk_pk_asTitle(this.m_collectible.friendlyName));
            if(Global.player.collectionCounters[this.m_collectible.code] > 0)
            {
               this.m_icon.element.filters = [];
               this.m_collectibleBackground.visible = true;
               if(this.m_collectible.numNeeded <= Global.player.collectionCounters[this.m_collectible.code])
               {
                  this.m_checkmark.visible = true;
               }
            }
            else
            {
               this.m_icon.element.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
               this.m_emptyBackground.visible = true;
            }
            if(this.m_collectible.rarityNumber == 0 && ExternalInterface.available && this.m_collectible.numOwned < this.m_collectible.numNeeded && GlobalEngine.serverTime - Global.player.getFeatureLastShown(CollectionsManager.FRIEND_REWARD_ACTION_KEY) > CollectionsManager.getInstance().getConfigAttribute(CollectionsManager.FRIEND_REWARD_TIME_LIMIT))
            {
               this.m_ask.visible = true;
               this.m_askButtonText.visible = true;
            }
         }
         this.m_collectibleCount.visible = true;
         this.m_rarity.visible = true;
         this.m_icon.visible = true;
         this.m_ask.visible = false;
      }
   }
}

