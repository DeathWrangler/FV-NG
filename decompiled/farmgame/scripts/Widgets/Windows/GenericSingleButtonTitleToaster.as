package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class GenericSingleButtonTitleToaster extends ToasterWindow
   {
      
      private var m_title:String;
      
      private var m_description:String;
      
      private var m_buttonText:String;
      
      private var m_callback:Function;
      
      private var m_callbackParams:Object;
      
      private var m_statsCounter:String;
      
      public function GenericSingleButtonTitleToaster(assetUrl:String, title:String, description:String, buttonText:String, buttonCallback:Function, callbackPrams:Object = null, statsCounter:String = null)
      {
         super(assetUrl);
         this.m_title = title;
         this.m_description = description;
         this.m_buttonText = buttonText;
         this.m_callback = buttonCallback;
         this.m_callbackParams = callbackPrams;
         this.m_statsCounter = statsCounter;
      }
      
      override protected function postLoadComplete() : void
      {
         var button:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         if(m_window)
         {
            addWidget(new ZwTextField(m_window.title_tf,this.m_title));
            addWidget(new ZwTextField(m_window.description_tf,this.m_description));
            if(m_window["accept_bt"])
            {
               if(this.m_buttonText == "")
               {
                  button = new FarmAnimatedTextButton(m_window.accept_bt,"Play",this.onAccept);
               }
               else
               {
                  button = new FarmAnimatedTextButton(m_window.accept_bt,this.m_buttonText,this.onAccept);
               }
               addWidget(button,true);
            }
            this.conditionallyCount(StatsTrackingConstants.IMPRESSIONS);
         }
      }
      
      public function onAccept(click:MouseEvent) : void
      {
         if(this.m_callbackParams)
         {
            this.m_callback(this.m_callbackParams);
         }
         else
         {
            this.m_callback();
         }
         this.conditionallyCount(StatsTrackingConstants.CLICKS);
      }
      
      private function conditionallyCount(phylum:String) : void
      {
         if(this.m_statsCounter)
         {
            StatsManager.count(this.m_statsCounter,StatsTrackingConstants.TOASTER,phylum);
         }
      }
   }
}

