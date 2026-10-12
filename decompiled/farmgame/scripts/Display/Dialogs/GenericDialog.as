package Display.Dialogs
{
   import Display.FarmDynamicDialog;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   
   public class GenericDialog extends FarmDynamicDialog
   {
      
      private static var m_colorToImportMap:Dictionary;
      
      private var m_config:GenericDialogConfig;
      
      public function GenericDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function createFromConfig(config:GenericDialogConfig) : GenericDialog
      {
         var result:GenericDialog = null;
         if(config)
         {
            if(config.getBodyText() != null || config.getImageUrl() != null)
            {
               if(config.hasCloseButton() || config.buttonCount() > 0)
               {
                  result = FarmDynamicDialog.createDialog("GenericDialog",GenericDialog) as GenericDialog;
                  if(result)
                  {
                     result.setConfig(config);
                  }
               }
            }
         }
         return result;
      }
      
      public function setConfig(config:GenericDialogConfig) : void
      {
         this.m_config = config;
         this.updateConfig();
      }
      
      private function updateConfig() : void
      {
         var index:int = 0;
         var newButton:BaseWidgetController = null;
         var callback:Function = null;
         var hasData:Boolean = false;
         hasData = this.m_config.getTitleText() != null;
         this.toggleOption("titleBar",hasData);
         if(hasData)
         {
            setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,this.m_config.getTitleText());
         }
         hasData = this.m_config.getBodyText() != null;
         this.toggleOption("bodyText",hasData);
         if(hasData)
         {
            if(this.m_config.hasCenteredText())
            {
               setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_ALIGN,TextFormatAlign.CENTER);
            }
            setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,this.m_config.getBodyText());
         }
         hasData = this.m_config.getImageUrl() != null;
         this.toggleOption("image",hasData);
         if(hasData)
         {
            setShortcutAttribute("image",ImageController.ATTRIBUTE_SOURCE,this.m_config.getImageUrl());
         }
         hasData = this.m_config.getName() != null;
         this.toggleOption("name",hasData);
         if(hasData)
         {
            setAttribute(BaseWidgetController.ATTRIBUTE_NAME,this.m_config.getName());
         }
         setShortcutAttribute("CloseButtonView",BaseWidgetView.ATTRIBUTE_VISIBLE,this.m_config.hasCloseButton());
         var buttonHolder:BaseWidgetController = this.getShortcutController("buttonHolder");
         if(buttonHolder)
         {
            buttonHolder.removeChildControllers();
            if(this.m_config.buttonCount() > 0)
            {
               for(index = 0; index < this.m_config.buttonCount(); index++)
               {
                  newButton = this.getButtonByColor(this.m_config.getButtonColor(index));
                  if(newButton)
                  {
                     newButton.setAttribute(ButtonController.ATTRIBUTE_TEXT,this.m_config.getButtonText(index));
                     callback = this.m_config.getButtonCallback(index);
                     if(callback == null)
                     {
                        callback = this.onButtonPressed;
                     }
                     newButton.listen(WidgetControllerEvent.BUTTON_PRESSED,callback);
                     buttonHolder.addChildController(newButton);
                  }
               }
            }
         }
      }
      
      private function toggleOption(shortcutName:String, value:Boolean) : void
      {
         setShortcutAttribute(shortcutName,BaseWidgetView.ATTRIBUTE_OBSTRUCT,value);
         setShortcutAttribute(shortcutName,BaseWidgetView.ATTRIBUTE_VISIBLE,value);
      }
      
      private function onButtonPressed(event:WidgetControllerEvent) : void
      {
         this.destroy();
      }
      
      private function getButtonByColor(colorName:String) : BaseWidgetController
      {
         var view:BaseWidgetView = null;
         var result:BaseWidgetController = null;
         if(m_colorToImportMap == null)
         {
            m_colorToImportMap = new Dictionary();
            m_colorToImportMap[GenericDialogConfig.COLOR_GREEN] = "GreenButtonView";
            m_colorToImportMap[GenericDialogConfig.COLOR_RED] = "RedButtonView";
            m_colorToImportMap[GenericDialogConfig.COLOR_BLUE] = "BlueButtonView";
            m_colorToImportMap[GenericDialogConfig.COLOR_TEAL] = "TealButtonView";
         }
         if(m_colorToImportMap[colorName])
         {
            view = getImport(m_colorToImportMap[colorName]) as BaseWidgetView;
            if(view)
            {
               result = view.getController().clone();
            }
         }
         return result;
      }
   }
}

