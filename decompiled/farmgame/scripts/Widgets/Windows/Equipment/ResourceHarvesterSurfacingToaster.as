package Widgets.Windows.Equipment
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.ToasterWindow;
   import flash.events.MouseEvent;
   
   public class ResourceHarvesterSurfacingToaster extends ToasterWindow
   {
      
      protected static const DEFAULT_SURFACING_TOASTER_WAIT_DAYS:int = 7;
      
      protected var m_titleText:String = "";
      
      protected var m_descriptionText:String = "";
      
      protected var m_acceptButtonText:String = "";
      
      public function ResourceHarvesterSurfacingToaster(asset:String)
      {
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmTextField(m_window.title_tf,this.m_titleText));
         addWidget(new FarmTextField(m_window.description_tf,this.m_descriptionText));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,this.m_acceptButtonText,this.onAcceptButtonClick));
      }
      
      protected function onAcceptButtonClick(event:MouseEvent) : void
      {
      }
   }
}

