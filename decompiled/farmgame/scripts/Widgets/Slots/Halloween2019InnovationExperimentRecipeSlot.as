package Widgets.Slots
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Halloween2019InnovationCandyConversionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class Halloween2019InnovationExperimentRecipeSlot extends ZwSlotFrame
   {
      
      private static const CANDY_RECIPE_0_MC:String = "candy_recipe_0_mc";
      
      private static const CANDY_RECIPE_1_MC:String = "candy_recipe_1_mc";
      
      private static const TRY_BT:String = "try_bt";
      
      private static const WRONG_ICON_MC:String = "wrong_icon_mc";
      
      private static const QUESTION_MARK_MC:String = "question_mark_mc";
      
      private static const DEFAULT_TRY_TIME:int = 14400;
      
      private var m_featureName:String;
      
      private var m_owner:Halloween2019InnovationCandyConversionWindow;
      
      private var m_candyRecipe0Mc:FarmIcon;
      
      private var m_candyRecipe1Mc:FarmIcon;
      
      private var m_tryBt:FarmAnimatedTextButton;
      
      private var m_wrongIconMc:MovieClip;
      
      private var m_base:String;
      
      private var m_coat:String;
      
      private var m_questionMarkMc:MovieClip;
      
      private var m_candyReqIconMc:FarmIcon;
      
      private var m_questionTf:ZwTextField;
      
      public function Halloween2019InnovationExperimentRecipeSlot(featureName:String, element:DisplayObject, window:Halloween2019InnovationCandyConversionWindow)
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
         if(m_element.hasOwnProperty(TRY_BT))
         {
            this.m_tryBt = new FarmAnimatedTextButton(m_element[TRY_BT],"Try",this.onTrySpecialRecipe);
            this.m_tryBt.visible = true;
            this.m_tryBt.enabled = false;
         }
         if(m_element.hasOwnProperty(WRONG_ICON_MC))
         {
            this.m_wrongIconMc = m_element[WRONG_ICON_MC] as MovieClip;
            this.m_wrongIconMc.visible = false;
         }
         if(m_element.hasOwnProperty(QUESTION_MARK_MC))
         {
            this.m_questionMarkMc = m_element[QUESTION_MARK_MC] as MovieClip;
            this.m_questionMarkMc.visible = false;
            if(this.m_questionMarkMc.hasOwnProperty("candy_req_icon_mc"))
            {
               addWidget(this.m_candyReqIconMc = new FarmIcon(this.m_questionMarkMc["candy_req_icon_mc"]));
               this.m_candyReqIconMc.visible = false;
            }
            if(this.m_questionMarkMc.hasOwnProperty("question_tf"))
            {
               addWidget(this.m_questionTf = new ZwTextField(this.m_questionMarkMc["question_tf"]));
               this.m_questionTf.visible = false;
            }
         }
      }
      
      private static function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance();
      }
      
      public function onTrySpecialRecipe(event:Event) : void
      {
         manager.addNormalCandiesToStation(this.m_base,this.m_coat);
      }
      
      override public function populate(data:Object) : void
      {
         var specialCandyIconVisibility:Boolean = false;
         var specialCandyName:String = null;
         this.m_base = data["baseCandyName"];
         this.m_coat = data["coatCandyName"];
         this.m_tryBt.enabled = false;
         this.m_candyRecipe0Mc.loadIcon(data["baseCandyURL"]);
         this.m_candyRecipe0Mc.setIconSize(50,50);
         this.m_candyRecipe0Mc.visible = true;
         this.m_candyRecipe1Mc.loadIcon(data["coatCandyURL"]);
         this.m_candyRecipe1Mc.setIconSize(50,50);
         this.m_candyRecipe1Mc.visible = true;
         if(manager.isBaseCoatTried(this.m_base,this.m_coat))
         {
            this.m_tryBt.visible = false;
            this.m_questionMarkMc.visible = true;
            this.m_questionTf.visible = false;
            this.m_candyReqIconMc.visible = false;
            if(manager.isBaseCoatFormSpecialCandy(this.m_base,this.m_coat))
            {
               specialCandyIconVisibility = manager.isSpecialCandyVisited(manager.getSpecialCandyByBaseCoat(this.m_base,this.m_coat));
               if(specialCandyIconVisibility)
               {
                  this.m_questionTf.visible = true;
               }
               else
               {
                  specialCandyName = manager.getSpecialCandyByBaseCoat(this.m_base,this.m_coat);
                  this.m_candyReqIconMc.loadIcon(manager.getSpecialCandyURLByName(specialCandyName));
                  this.m_candyReqIconMc.setIconSize(40,40);
                  this.m_candyReqIconMc.visible = true;
               }
            }
            else
            {
               this.m_wrongIconMc.visible = true;
            }
         }
         else if(data["baseCandyCount"] >= 1 && data["coatCandyCount"] >= 1)
         {
            this.m_tryBt.enabled = true;
            this.m_questionMarkMc.visible = true;
            this.m_questionTf.visible = true;
            this.m_candyRecipe0Mc.attachTooltip(new FarmTextTooltip(data["baseCandyName"]));
            this.m_candyRecipe1Mc.attachTooltip(new FarmTextTooltip(data["coatCandyName"]));
         }
      }
   }
}

