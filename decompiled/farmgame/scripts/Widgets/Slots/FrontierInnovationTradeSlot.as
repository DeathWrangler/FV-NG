package Widgets.Slots
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FrontierInnovationTradeSlot extends ZwSlotFrame
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
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      private var m_checkmark:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_selectTf:ZwTextField;
      
      private var m_hoverMc:MovieClip;
      
      private var m_discardBt:FarmAnimatedTextButton;
      
      private var m_tradeBt:FarmAnimatedTextButton;
      
      private var m_itemHover:ZwWidget;
      
      private var m_glowMc:MovieClip;
      
      private var m_selectResourceBt:FarmAnimatedTextButton;
      
      private const HOVER_MC:String = "hover_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SELECT_TF:String = "select_tf";
      
      private const ITEM_HOVER:String = "item_hover";
      
      private const HOVER_GLOW:String = "hover_glow";
      
      internal var manager:FrontierInnovationManager;
      
      private var m_featureName:String;
      
      private var m_slotResource:String;
      
      private var m_frameName:String;
      
      private var m_slotNumber:int;
      
      private var m_slotResourceName:String;
      
      private var m_window:FrontierInnovationBarnWindow;
      
      internal var index:*;
      
      public function FrontierInnovationTradeSlot(featureName:String, element:DisplayObject, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
      }
   }
}

