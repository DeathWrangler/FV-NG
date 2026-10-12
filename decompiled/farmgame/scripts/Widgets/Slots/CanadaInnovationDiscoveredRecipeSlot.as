package Widgets.Slots
{
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.CanadaInnovationCandyConversionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CanadaInnovationDiscoveredRecipeSlot extends ZwSlotFrame
   {
      
      private static const CANDY_RECIPE_0_MC:String = "candy_recipe_0_mc";
      
      private static const CANDY_RECIPE_1_MC:String = "candy_recipe_1_mc";
      
      private static const CANDY_RECIPE_2_MC:String = "candy_recipe_2_mc";
      
      private static const MAKE_BT:String = "make_bt";
      
      private static const QUESTION_MARK_MC:String = "question_mark_mc";
      
      private static const REVEAL_TIMER_MC:String = "reveal_timer_mc";
      
      private static const TIMER_TF:String = "timer_tf";
      
      private static const MAKE_TIME:int = 6;
      
      private var m_featureName:String;
      
      private var m_owner:CanadaInnovationCandyConversionWindow;
      
      private var m_candyRecipe0Mc:FarmIcon;
      
      private var m_candyRecipe1Mc:FarmIcon;
      
      private var m_candyRecipe2Mc:FarmIcon;
      
      private var m_makeBt:FarmAnimatedTextButton;
      
      private var m_specialCandyName:String;
      
      private var m_questionMarkMc:MovieClip;
      
      private var m_revealTimerMc:MovieClip;
      
      private var m_timerTf:ZwTextField;
      
      public function CanadaInnovationDiscoveredRecipeSlot(featureName:String, element:DisplayObject, window:CanadaInnovationCandyConversionWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(CANDY_RECIPE_0_MC))
         {
            addWidget(this.m_candyRecipe0Mc = new FarmIcon(m_element[CANDY_RECIPE_0_MC]));
            this.m_candyRecipe0Mc.visible = true;
         }
         if(m_element.hasOwnProperty(CANDY_RECIPE_1_MC))
         {
            addWidget(this.m_candyRecipe1Mc = new FarmIcon(m_element[CANDY_RECIPE_1_MC]));
            this.m_candyRecipe1Mc.visible = true;
         }
         if(m_element.hasOwnProperty(CANDY_RECIPE_2_MC))
         {
            addWidget(this.m_candyRecipe2Mc = new FarmIcon(m_element[CANDY_RECIPE_2_MC]));
            this.m_candyRecipe2Mc.visible = false;
         }
         if(m_element.hasOwnProperty(MAKE_BT))
         {
            this.m_makeBt = new FarmAnimatedTextButton(m_element[MAKE_BT],"Make",this.onMakeSpecialRecipe);
            this.m_makeBt.visible = false;
         }
         if(m_element.hasOwnProperty(QUESTION_MARK_MC))
         {
            this.m_questionMarkMc = m_element[QUESTION_MARK_MC] as MovieClip;
            this.m_questionMarkMc.visible = false;
         }
         if(m_element.hasOwnProperty(REVEAL_TIMER_MC))
         {
            this.m_revealTimerMc = m_element[REVEAL_TIMER_MC] as MovieClip;
            this.m_revealTimerMc.visible = false;
            if(this.m_revealTimerMc.hasOwnProperty(TIMER_TF))
            {
               addWidget(this.m_timerTf = new ZwTextField(this.m_revealTimerMc[TIMER_TF]));
               this.m_timerTf.visible = false;
            }
         }
      }
      
      private static function get manager() : CanadaInnovationManager
      {
         return CanadaInnovationManager.getInstance();
      }
      
      public function onMakeSpecialRecipe(event:Event) : void
      {
      }
      
      override public function populate(data:Object) : void
      {
         this.m_specialCandyName = data["specialCandy"];
         this.m_candyRecipe0Mc.loadIcon(data["baseCandyUrl"]);
         this.m_candyRecipe0Mc.setIconSize(40,40);
         this.m_candyRecipe0Mc.attachTooltip(new FarmTextTooltip(data["baseCandy"]));
         this.m_candyRecipe0Mc.visible = true;
         this.m_candyRecipe1Mc.loadIcon(data["coatCandyUrl"]);
         this.m_candyRecipe1Mc.setIconSize(40,40);
         this.m_candyRecipe1Mc.attachTooltip(new FarmTextTooltip(data["coatCandy"]));
         this.m_candyRecipe1Mc.visible = true;
         this.m_revealTimerMc.visible = false;
         this.m_makeBt.visible = false;
         this.m_candyRecipe2Mc.visible = false;
         this.m_questionMarkMc.visible = false;
         if(data["makeBTVisibility"])
         {
            this.m_makeBt.visible = true;
            this.m_makeBt.enabled = data["makeBTVisibility"];
         }
         else
         {
            this.m_revealTimerMc.visible = true;
            this.m_timerTf.visible = true;
            this.m_timerTf.text = (MAKE_TIME - manager.getSpecialCandyMakeTime(data["specialCandy"])).toString() + "minute(s)";
         }
         this.m_questionMarkMc.visible = data["specialCandyIconVisibility"];
         if(data["specialCandyIconVisibility"])
         {
            this.m_questionMarkMc.visible = data["specialCandyIconVisibility"];
         }
         else
         {
            this.m_candyRecipe2Mc.loadIcon(data["specialCandyUrl"]);
            this.m_candyRecipe2Mc.setIconSize(40,40);
            this.m_candyRecipe2Mc.attachTooltip(new FarmTextTooltip(data["specialCandy"]));
            this.m_candyRecipe2Mc.visible = true;
         }
      }
   }
}

