package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.utils.StringUtil;
   
   public class HalloweenInnovationGhoulInventionBaseSlot extends ZwSlotFrame
   {
      
      private static const CHECKPOINT0_MC:String = "checkpoint0_mc";
      
      private static const CHECKPOINT1_MC:String = "checkpoint1_mc";
      
      private static const CHECKPOINT2_MC:String = "checkpoint2_mc";
      
      private static const CHECKPOINT3_MC:String = "checkpoint3_mc";
      
      private const IMAGE_MC:String = "image_mc";
      
      private const PART1_MC:String = "part1_mc";
      
      private const PART1_PREVIEW_MC:String = "part1_preview_mc";
      
      private const PART2_MC:String = "part2_mc";
      
      private const PART2_PREVIEW_MC:String = "part2_preview_mc";
      
      private const PART3_MC:String = "part3_mc";
      
      private const PART3_PREVIEW_MC:String = "part3_preview_mc";
      
      private const PART4_MC:String = "part4_mc";
      
      private const PART4_PREVIEW_MC:String = "part4_preview_mc";
      
      private const PROGRESS_BAR_MC:String = "progressbar_mc";
      
      private const INVENTION_TF:String = "invention_tf";
      
      private const BAR_FILL0_MC:String = "barfill0_mc";
      
      private const BAR_FILL1_MC:String = "barfill1_mc";
      
      private const BAR_FILL2_MC:String = "barfill2_mc";
      
      private const HIT_AREA_MC:String = "hit_area_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const REWARD_ICONS:Array = ["furryfreak","madclaw","supremeshell","darkdoom"];
      
      private var m_featureName:String = "";
      
      private var m_manager:HalloweenInnovationGhoulManager = null;
      
      private var m_imageMc:FarmIcon;
      
      private var m_part1Mc:MovieClip;
      
      private var m_part1PreviewMc:MovieClip;
      
      private var m_part2Mc:MovieClip;
      
      private var m_part2PreviewMc:MovieClip;
      
      private var m_part3Mc:MovieClip;
      
      private var m_part3PreviewMc:MovieClip;
      
      private var m_part4Mc:MovieClip;
      
      private var m_part4PreviewMc:MovieClip;
      
      private var m_progressBarMc:MovieClip;
      
      private var m_inventionTf:ZwTextField;
      
      private var m_barFill0Mc:MovieClip;
      
      private var m_barFill1Mc:MovieClip;
      
      private var m_barFill2Mc:MovieClip;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_hitAreaMc:ZwWidget;
      
      public var m_slotIndex:int;
      
      private var m_progressBarStageToPartMap:Object = {};
      
      public var m_activePart:int;
      
      public var m_activeInvention:int;
      
      private var m_checkPoint0MC:MovieClip;
      
      private var m_checkPoint1MC:MovieClip;
      
      private var m_checkPoint2MC:MovieClip;
      
      private var m_checkPoint3MC:MovieClip;
      
      private var m_hitAreaPreviewMc:MovieClip;
      
      private var m_partPreviews:Array = [this.PART1_PREVIEW_MC,this.PART2_PREVIEW_MC,this.PART3_PREVIEW_MC,this.PART4_PREVIEW_MC];
      
      public function HalloweenInnovationGhoulInventionBaseSlot(element:DisplayObject, featureName:String, manager:HalloweenInnovationGhoulManager, activeInvention:int, inventionIndex:int)
      {
         this.m_featureName = featureName;
         this.m_manager = manager;
         super(element);
         m_element.addEventListener(MouseEvent.MOUSE_OVER,this.onProgressBarMouseRollOver);
         m_element.addEventListener(MouseEvent.MOUSE_OUT,this.onProgressBarMouseRollOut);
         if(m_element.hasOwnProperty(this.IMAGE_MC))
         {
            this.m_imageMc = new FarmIcon(m_element[this.IMAGE_MC]);
            this.m_imageMc.visible = true;
         }
         if(m_element.hasOwnProperty(this.HIT_AREA_MC))
         {
            if(activeInvention <= inventionIndex)
            {
               this.m_hitAreaPreviewMc = m_element[this.HIT_AREA_MC] as MovieClip;
               this.m_hitAreaPreviewMc.visible = false;
               this.m_hitAreaPreviewMc.addEventListener(MouseEvent.MOUSE_OVER,this.onHitAreaMouseRollOver);
               this.m_hitAreaPreviewMc.addEventListener(MouseEvent.MOUSE_OUT,this.onHitAreaMouseRollOut);
            }
            else
            {
               this.m_hitAreaMc = new ZwWidget(m_element[this.HIT_AREA_MC]);
               this.m_hitAreaMc.visible = false;
            }
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkmarkMc = m_element[this.CHECKMARK_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.PART1_MC))
         {
            this.m_part1Mc = m_element[this.PART1_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.PART1_PREVIEW_MC))
         {
            this.m_part1PreviewMc = m_element[this.PART1_PREVIEW_MC] as MovieClip;
            this.m_part1PreviewMc.visible = true;
            this.m_progressBarStageToPartMap[this.PART1_PREVIEW_MC] = this.m_part1Mc;
         }
         if(m_element.hasOwnProperty(this.PART2_MC))
         {
            this.m_part2Mc = m_element[this.PART2_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.PART2_PREVIEW_MC))
         {
            this.m_part2PreviewMc = m_element[this.PART2_PREVIEW_MC] as MovieClip;
            this.m_part2PreviewMc.visible = true;
            this.m_progressBarStageToPartMap[this.PART2_PREVIEW_MC] = this.m_part2Mc;
         }
         if(m_element.hasOwnProperty(this.PART3_MC))
         {
            this.m_part3Mc = m_element[this.PART3_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.PART3_PREVIEW_MC))
         {
            this.m_part3PreviewMc = m_element[this.PART3_PREVIEW_MC] as MovieClip;
            this.m_part3PreviewMc.visible = true;
            this.m_progressBarStageToPartMap[this.PART3_PREVIEW_MC] = this.m_part3Mc;
         }
         if(m_element.hasOwnProperty(this.PART4_MC))
         {
            this.m_part4Mc = m_element[this.PART4_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.PART4_PREVIEW_MC))
         {
            this.m_part4PreviewMc = m_element[this.PART4_PREVIEW_MC] as MovieClip;
            this.m_part4PreviewMc.visible = true;
            this.m_progressBarStageToPartMap[this.PART4_PREVIEW_MC] = this.m_part4Mc;
         }
         if(m_element.hasOwnProperty(this.PROGRESS_BAR_MC))
         {
            this.m_progressBarMc = m_element[this.PROGRESS_BAR_MC] as MovieClip;
            if(this.m_progressBarMc.hasOwnProperty(this.BAR_FILL0_MC))
            {
               this.m_barFill0Mc = this.m_progressBarMc[this.BAR_FILL0_MC] as MovieClip;
               this.m_barFill0Mc.visible = false;
            }
            if(this.m_progressBarMc.hasOwnProperty(this.BAR_FILL1_MC))
            {
               this.m_barFill1Mc = this.m_progressBarMc[this.BAR_FILL1_MC] as MovieClip;
               this.m_barFill1Mc.visible = false;
            }
            if(this.m_progressBarMc.hasOwnProperty(this.BAR_FILL2_MC))
            {
               this.m_barFill2Mc = this.m_progressBarMc[this.BAR_FILL2_MC] as MovieClip;
               this.m_barFill2Mc.visible = false;
            }
            if(this.m_progressBarMc.hasOwnProperty(CHECKPOINT0_MC))
            {
               this.m_checkPoint0MC = this.m_progressBarMc[CHECKPOINT0_MC] as MovieClip;
               this.m_checkPoint0MC.gotoAndStop(0);
               this.m_checkPoint0MC.visible = true;
            }
            if(this.m_progressBarMc.hasOwnProperty(CHECKPOINT1_MC))
            {
               this.m_checkPoint1MC = this.m_progressBarMc[CHECKPOINT1_MC] as MovieClip;
               this.m_checkPoint1MC.gotoAndStop(0);
               this.m_checkPoint1MC.visible = true;
            }
            if(this.m_progressBarMc.hasOwnProperty(CHECKPOINT2_MC))
            {
               this.m_checkPoint2MC = this.m_progressBarMc[CHECKPOINT2_MC] as MovieClip;
               this.m_checkPoint2MC.gotoAndStop(0);
               this.m_checkPoint2MC.visible = true;
            }
            if(this.m_progressBarMc.hasOwnProperty(CHECKPOINT3_MC))
            {
               this.m_checkPoint3MC = this.m_progressBarMc[CHECKPOINT3_MC] as MovieClip;
               this.m_checkPoint3MC.gotoAndStop(0);
               this.m_checkPoint3MC.visible = true;
            }
            this.m_progressBarMc.visible = true;
         }
         if(m_element.hasOwnProperty(this.INVENTION_TF))
         {
            this.m_inventionTf = addWidget(new ZwTextField(m_element[this.INVENTION_TF],"")) as ZwTextField;
            this.m_inventionTf.visible = true;
         }
      }
      
      public function onHitAreaMouseRollOver(event:MouseEvent) : void
      {
         this.m_manager.enableInventionPreviewFrame(true,this.m_slotIndex);
      }
      
      public function onHitAreaMouseRollOut(event:MouseEvent) : void
      {
         this.m_manager.disbaleInventionPreviewFrame();
      }
      
      private function eventTargetIsProgressBar(event:Event) : Boolean
      {
         if(!event.target.hasOwnProperty("name"))
         {
            return false;
         }
         var elementName:String = event.target.name;
         return this.m_partPreviews.indexOf(elementName) >= 0;
      }
      
      private function onProgressBarMouseRollOut(event:MouseEvent) : void
      {
         var elementName:String = event.target.name;
         if(!this.eventTargetIsProgressBar(event))
         {
            return;
         }
         this.m_progressBarStageToPartMap[elementName].visible = false;
      }
      
      private function onProgressBarMouseRollOver(event:MouseEvent) : void
      {
         if(!this.eventTargetIsProgressBar(event) || this.m_activeInvention != this.m_slotIndex)
         {
            return;
         }
         var elementName:String = event.target.name;
         this.m_progressBarStageToPartMap[elementName].visible = true;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_checkmarkMc.visible = false;
         this.m_slotIndex = data.Index;
         this.m_activePart = data.ActivePart;
         this.m_activeInvention = data.ActiveInvention;
         this.m_inventionTf.visible = true;
         this.m_inventionTf.text = data.InventionName;
         this.release();
      }
      
      private function attachHarvestTooltipConditionally() : void
      {
         var itemName:String = this.m_manager.m_mapInventionToDeco[this.m_slotIndex];
         var harvestTime:String = this.m_manager.getHarvestTime(itemName);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var toolTipText:String = "You have invented this! Harvest this until 10th December, 2018.";
         var key:String = itemName + this.m_manager.LAST_HARVEST_TIME_KEY;
         if(Boolean(Global.player.getFeatureLastShown(key)) && this.m_manager.isDecosReadyForHarvest(itemName) == false)
         {
            toolTipText = toolTipText + "\n" + item.friendlyTitle + " Next harvest in " + harvestTime;
         }
         else
         {
            toolTipText += "Harvest now.";
         }
         if(!this.m_hitAreaMc)
         {
            this.m_hitAreaMc = new ZwWidget(m_element[this.HIT_AREA_MC]);
            this.m_hitAreaPreviewMc.visible = false;
            this.m_hitAreaPreviewMc.removeEventListener(MouseEvent.MOUSE_OVER,this.onHitAreaMouseRollOver);
            this.m_hitAreaPreviewMc.removeEventListener(MouseEvent.MOUSE_OUT,this.onHitAreaMouseRollOut);
         }
         this.m_hitAreaMc.attachTooltip(new FarmTextTooltip(toolTipText));
      }
      
      override public function release() : void
      {
         var i:int = 0;
         var barFills:Array = [this.m_barFill0Mc,this.m_barFill1Mc,this.m_barFill2Mc];
         var checkpoints:Array = [this.m_checkPoint0MC,this.m_checkPoint1MC,this.m_checkPoint2MC,this.m_checkPoint3MC];
         if(Boolean(this.m_hitAreaMc) && Boolean(this.m_hitAreaMc.tooltip))
         {
            this.m_hitAreaMc.detachTooltip();
         }
         if(this.m_activeInvention > this.m_slotIndex)
         {
            this.m_imageMc.loadIcon(Global.getAssetURL(StringUtil.substitute("assets/decorations/marbless{0}.swf",this.REWARD_ICONS[this.m_slotIndex])));
            this.m_imageMc.setIconSize(100,100);
            this.attachHarvestTooltipConditionally();
            this.m_hitAreaMc.visible = true;
            i = 0;
            while(i < barFills.length)
            {
               barFills[i].visible = false;
               i++;
            }
            i = 0;
            while(i < checkpoints.length)
            {
               checkpoints[i].visible = false;
               i++;
            }
            this.m_checkmarkMc.visible = true;
         }
         else
         {
            this.m_imageMc.loadIcon(this.m_manager.getAssetURL(this.m_manager.ANIMAL_ICON,this.m_slotIndex,0));
            this.m_hitAreaPreviewMc.visible = true;
         }
         if(this.m_activeInvention == this.m_slotIndex)
         {
            checkpoints[this.m_activePart].gotoAndStop(3);
            this.m_imageMc.loadIcon(this.m_manager.getAssetURL(this.m_manager.ANIMAL_ICON,this.m_slotIndex,this.m_activePart));
            for(i = 0; i < this.m_activePart; i++)
            {
               barFills[i].visible = true;
               checkpoints[i].gotoAndStop(2);
            }
         }
      }
   }
}

