package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureCrafting.FeatureCraftingNPC;
   import Classes.Quest.PrerequisiteUtility;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.TemplateUIUtility;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingNPCWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingNPCSlot extends ZwSlotFrame
   {
      
      private static const UNLOCKED_ALPHA:Number = 1;
      
      private static const LOCKED_ALPHA:Number = 0.6;
      
      protected var m_data:FeatureCraftingNPC;
      
      private var m_previewFrame:ResourcePreviewFrame;
      
      private var m_hitWidget:ZwWidget;
      
      private var m_lockWidget:ZwWidget;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_infoTextField:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_actionTooltip:WidgetTooltip;
      
      private var m_completedWidget:ZwWidget;
      
      private var m_screenWidget:ZwWidget;
      
      private var m_location:String = "";
      
      public function FeatureCraftingNPCSlot(element:DisplayObject, location:String = "")
      {
         super(element);
         this.m_location = location;
         this.m_previewFrame = addWidget(new ResourcePreviewFrame(m_element.icon_mc)) as ResourcePreviewFrame;
         this.m_lockWidget = addWidget(new ZwWidget(m_element.locked_mc),false) as ZwWidget;
         this.m_completedWidget = addWidget(new ZwWidget(m_element.complete_mc),false) as ZwWidget;
         if(m_element.screen_mc)
         {
            this.m_screenWidget = addWidget(new ZwWidget(m_element.screen_mc),false) as ZwWidget;
         }
         if(m_element.hit_bt)
         {
            this.m_hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
            (this.m_hitWidget.element as SimpleButton).addEventListener(MouseEvent.CLICK,this.onClick);
            (this.m_hitWidget.element as SimpleButton).useHandCursor = true;
         }
         var tooltipFrame:ZwFrame = new ZwFrame(m_element.tooltip_mc) as ZwFrame;
         this.m_nameTextField = tooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.header_tf," ")) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.tooltip_mc.header_tf);
         }
         this.m_infoTextField = tooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.subheader_tf," ")) as ZwTextField;
         this.m_buyButton = tooltipFrame.addWidget(new FarmAnimatedCashButton(m_element.tooltip_mc.buyAll_bt,"","",this.onBuyButtonClick)) as FarmAnimatedCashButton;
         this.m_actionTooltip = new WidgetTooltip(tooltipFrame);
         this.m_actionTooltip.fixed = true;
         this.m_actionTooltip.interactive = true;
         attachTooltip(this.m_actionTooltip);
      }
      
      override public function release() : void
      {
         if(this.m_hitWidget)
         {
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.CLICK,this.onClick);
         }
         this.m_hitWidget = null;
         this.m_previewFrame = null;
         this.m_lockWidget = null;
         this.m_nameTextField = null;
         this.m_infoTextField = null;
         this.m_buyButton = null;
         this.m_actionTooltip = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingNPC;
         this.refresh(true);
      }
      
      public function refresh(reloadIcon:Boolean = false) : void
      {
         var WorldType:String = null;
         var seasons:int = 0;
         var playerNextSeason:int = 0;
         var currentSeason:int = 0;
         var accessType:String = null;
         var unlockDate:Object = null;
         if(this.m_data)
         {
            if(reloadIcon)
            {
               this.m_previewFrame.load(this.m_data.assetUrl,this.m_data.getFullExportName(FeatureCraftingNPC.ASSET_STATE_IDLE),this.repositionSlotPreviewFrame,this.m_data.autoScaling);
            }
            this.m_previewFrame.visible = true;
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            if(this.m_hitWidget)
            {
               this.m_hitWidget.visible = true;
            }
            this.m_lockWidget.visible = true;
            if(this.m_completedWidget)
            {
               this.m_completedWidget.visible = this.m_data.isComplete();
            }
            this.refreshState();
            if(this.m_screenWidget)
            {
               WorldType = WorldsConstants.WORLD_ID_JAPAN;
               if(WorldType != "" && this.m_data.prereqName != "" && !PrerequisiteUtility.checkPrereqByName(this.m_data.prereqName))
               {
                  this.m_screenWidget.visible = true;
                  if(m_element.hit_bt)
                  {
                     seasons = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(WorldType);
                     playerNextSeason = WorldSeasonsManager.getInstance().getNextPlayerSeason(WorldType);
                     currentSeason = WorldSeasonsManager.getInstance().getCurrentSeason(WorldType);
                     accessType = WorldSeasonsManager.getInstance().getAccessType(WorldType);
                     unlockDate = WorldSeasonsManager.getInstance().getSeasonUnlockETA(WorldType,playerNextSeason,accessType);
                     if(unlockDate.days > 0)
                     {
                        m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.days + " days";
                     }
                     else if(unlockDate.hours > 0)
                     {
                        m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.hours + " hours";
                     }
                     else if(unlockDate.minutes > 0)
                     {
                        m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.minutes + " minutes";
                     }
                     else if(unlockDate.seconds > 0)
                     {
                        m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.seconds + " seconds";
                     }
                     else
                     {
                        m_element.screen_mc.unlockInfo_tf.text = "Reload the game!";
                     }
                     (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.ROLL_OVER,detachTooltip);
                     (this.m_hitWidget.element as SimpleButton).useHandCursor = false;
                  }
               }
            }
         }
      }
      
      private function repositionSlotPreviewFrame() : void
      {
         var mc:MovieClip = this.m_previewFrame.exportedMovieClip;
         if(mc)
         {
            mc.y = -mc.height;
         }
      }
      
      public function refreshState() : void
      {
         if(Boolean(m_element) && Boolean(this.m_data))
         {
            if(this.m_data.unlocked)
            {
               this.m_previewFrame.alpha = UNLOCKED_ALPHA;
               this.m_lockWidget.visible = false;
               this.m_infoTextField.text = this.m_data.system.getLocalizedString("NPCTooltip_View");
               this.m_infoTextField.visible = true;
               this.m_buyButton.visible = false;
               this.m_buyButton.enabled = false;
            }
            else
            {
               this.m_previewFrame.alpha = LOCKED_ALPHA;
               this.m_lockWidget.visible = true;
               if(this.m_data.isNextToUnlock)
               {
                  this.m_buyButton.visible = true;
                  this.m_buyButton.enabled = true;
                  this.m_buyButton.text = this.m_data.system.getLocalizedString("NPCTooltip_UnlockButton");
                  this.m_buyButton.setAmountText(String(this.m_data.unlockNowCost));
               }
               else
               {
                  this.m_buyButton.visible = false;
                  this.m_buyButton.enabled = false;
               }
               this.m_infoTextField.text = this.m_data.system.getLocalizedString("NPCTooltip_Unlock",{"level":this.m_data.unlockLevel});
               this.m_infoTextField.visible = true;
            }
         }
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_data.unlocked)
         {
            FeatureCraftingNPCWindow.display(this.m_data);
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var message:String = null;
         if(this.m_buyButton.enabled)
         {
            message = this.m_data.system.getLocalizedString("NPCTooltip_UnlockButton_Confirmation",{
               "cost":this.m_data.unlockNowCost,
               "npcName":this.m_data.friendlyTitle
            });
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"FeatureCraftingUnlockNPC",true);
         }
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.m_data.buyUnlock();
            this.refreshState();
         }
      }
   }
}

