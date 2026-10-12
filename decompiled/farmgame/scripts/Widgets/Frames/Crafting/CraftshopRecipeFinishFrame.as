package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftshopRecipeFinishFrame extends ZwFrame
   {
      
      protected var m_recipeId:String;
      
      protected var m_finishIt:FarmAnimatedTextButton;
      
      protected var m_finishTime:ZwTextField;
      
      protected var m_timeBar:ZwWidget;
      
      protected var m_finishNow:FarmAnimatedTextButton;
      
      protected var m_callBackObject:Object;
      
      public function CraftshopRecipeFinishFrame(element:DisplayObject, callBackObject:Object)
      {
         this.m_callBackObject = callBackObject;
         super(element);
         addWidget(new ZwWidget(this.element.finishedGood_mc));
         addWidget(new ZwWidget(this.element.finishedGood_mc.sheen_mc));
         this.m_finishIt = addWidget(new FarmAnimatedTextButton(this.element.finishedGood_mc.finishIt_bt,ZLocUtils.t("Dialogs","CraftshopRecipeFinishFrame_finishIt_btn"),this.pressFinishIt)) as FarmAnimatedTextButton;
         addWidget(new ZwWidget(this.element.meterProduction_mc));
         this.m_timeBar = addWidget(new ZwWidget(this.element.meterProduction_mc.bar_mc)) as ZwWidget;
         this.m_finishTime = addWidget(new ZwTextField(this.element.meterProduction_mc.generic_tf,"redcipe_finished_generic2_tf")) as ZwTextField;
         addWidget(new ZwWidget(this.element.productionSlotModal_mc));
         this.m_finishNow = addWidget(new FarmAnimatedTextButton(this.element.productionSlotModal_mc.finishNow_bt,ZLocUtils.t("Dialogs","CraftshopRecipeFinishFrame_finishNow_btn"),this.pressFinishNow)) as FarmAnimatedTextButton;
      }
      
      public function update(data:Object) : void
      {
         this.m_widgetManager.hideAllWidgets();
         if(data.hasOwnProperty("recipeId"))
         {
            this.m_recipeId = data.recipeId;
         }
         if(data.hasOwnProperty("recipeState"))
         {
            switch(data.recipeState)
            {
               case "recipeComplete":
                  getWidget(element.finishedGood_mc).visible = true;
                  getWidget(element.finishedGood_mc.sheen_mc).visible = true;
                  this.m_finishIt.visible = true;
                  break;
               case "inProgress":
                  getWidget(element.meterProduction_mc).visible = true;
                  this.m_timeBar.width = 26.3 + 80 * data.percent;
                  this.m_timeBar.visible = true;
                  getWidget(element.productionSlotModal_mc).visible = true;
                  this.m_finishNow.visible = true;
                  if(data.hasOwnProperty("finishTime"))
                  {
                     this.m_finishTime.text = data.finishTime;
                     this.m_finishTime.visible = true;
                  }
            }
         }
      }
      
      public function pressFinishIt(event:MouseEvent) : void
      {
         this.m_callBackObject.finishRecipe(this.m_recipeId);
      }
      
      public function pressFinishNow(event:MouseEvent) : void
      {
         this.m_callBackObject.finishRecipeRushed(this.m_recipeId);
      }
   }
}

