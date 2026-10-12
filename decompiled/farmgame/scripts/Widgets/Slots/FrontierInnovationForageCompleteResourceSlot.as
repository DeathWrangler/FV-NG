package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FrontierInnovationForageCompleteResourceFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FrontierInnovationWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FrontierInnovationForageCompleteResourceSlot extends ZwSlotFrame
   {
      
      private static const OFFSET_OPF_Y:int = -20;
      
      private static const ICON_SIZE:int = 100;
      
      private var m_basketName:String;
      
      private var m_data:Object;
      
      private var m_shouldShowCheckMark:Boolean = false;
      
      private var m_shouldShowCommonBg:Boolean = false;
      
      private var m_callbacks:Object;
      
      private var m_countTextField:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_redeemButton:FarmAnimatedTextButton = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_checkMark:ZwWidget;
      
      private var m_areaTf:ZwTextField;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      private var m_checkmark:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_resourceglowMc:MovieClip;
      
      private const ICON_MC:String = "icon_mc";
      
      private const RESOURCEGLOW_MC:String = "resourceglow_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SELECT_TF:String = "select_tf";
      
      private const OVERLAY_MC:String = "overlay_mc";
      
      private const EMPTY_SLOT:int = -1;
      
      private const AREA_TF:String = "area_tf";
      
      private const AXE_MC:String = "axe_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const COMPLETE_MC:String = "complete_mc";
      
      private const RESOURCES_MC:String = "resources_mc";
      
      private const SKIP_BT:String = "skip_bt";
      
      private const TIMELEFT_TF:String = "timeleft_tf";
      
      internal var manager:FrontierInnovationManager;
      
      private var m_featureName:String;
      
      private var m_slotResource:String;
      
      private var m_slotNumber:int;
      
      private var m_frameName:String;
      
      private var m_slotResourceName:String;
      
      private var m_resourceCount:int;
      
      private var m_window:FrontierInnovationWindow;
      
      private var m_completeResourceFrame:FrontierInnovationForageCompleteResourceFrame;
      
      private var m_resourceFrame:FrontierInnovationForageCompleteResourceFrame;
      
      private var patternSlot:RegExp = /\d+/;
      
      public function FrontierInnovationForageCompleteResourceSlot(featureName:String, element:DisplayObject, window:FrontierInnovationWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = addWidget(new ZwTextField(m_element[this.COUNT_TF],"1")) as ZwTextField;
            this.m_countTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[this.ICON_MC]));
            this.m_iconMc.visible = true;
         }
         if(m_element.hasOwnProperty(this.RESOURCEGLOW_MC))
         {
            this.m_resourceglowMc = m_element[this.RESOURCEGLOW_MC] as MovieClip;
            this.m_resourceglowMc.visible = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.releaseResource();
         this.m_countTf.text = String(data["count"]);
         this.m_countTf.visible = true;
         this.m_iconMc.visible = true;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data["itemCode"]);
         this.m_iconMc.loadIcon(item.icon);
         var itemHoverTooltip:FarmTextTooltip = new FarmTextTooltip(item.friendlyTitle);
         this.m_iconMc.attachTooltip(itemHoverTooltip);
         this.m_iconMc.setIconSize(30,30);
         this.m_resourceglowMc.visible = true;
      }
      
      public function releaseResource() : void
      {
         this.m_iconMc.detachTooltip();
         this.m_iconMc.visible = false;
      }
   }
}

