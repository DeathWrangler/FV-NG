package com.troyer.widget.controller
{
   import com.troyer.widget.view.BaseWidgetView;
   
   public class TreeListController extends ListController
   {
      
      public static const TAB_INCREASE_CHARACTER:String = ">";
      
      public static const TAB_DECREASE_CHARACTER:String = "<";
      
      private static const TAB_AMOUNT:String = "    ";
      
      public function TreeListController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         if(param1 == ATTRIBUTE_OPTIONS && param2 is String)
         {
            m_optionString = param2;
            _loc3_ = String(param2).split(m_delimiter);
            m_options = new Array();
            _loc4_ = "";
            for each(_loc5_ in _loc3_)
            {
               if(_loc5_ == TAB_INCREASE_CHARACTER)
               {
                  _loc4_ += TAB_AMOUNT;
               }
               else if(_loc5_ == TAB_DECREASE_CHARACTER)
               {
                  _loc6_ = _loc4_.length;
                  _loc6_ = _loc6_ - TAB_AMOUNT.length;
                  if(_loc6_ <= 0)
                  {
                     _loc4_ = "";
                  }
                  else
                  {
                     _loc4_ = _loc4_.substr(0,_loc6_);
                  }
               }
               else
               {
                  m_options.push(_loc4_ + _loc5_);
               }
            }
            updateOptions();
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      public function getCurrentTreePath() : String
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         var _loc1_:String = "";
         if(Boolean(m_currentSelectedButton) && Boolean(m_optionString))
         {
            _loc2_ = String(m_optionString).split(m_delimiter);
            _loc3_ = m_currentSelectedButton.getAttribute(ButtonController.ATTRIBUTE_TEXT);
            _loc3_ = _loc3_.split(" ").join("");
            _loc4_ = _loc2_.indexOf(_loc3_);
            if(_loc4_ != -1)
            {
               _loc1_ = _loc3_;
               _loc5_ = true;
               _loc7_ = 0;
               _loc8_ = int(_loc4_ - 1);
               while(_loc8_ >= 0)
               {
                  _loc6_ = _loc2_[_loc8_];
                  if(_loc6_ == TreeListController.TAB_INCREASE_CHARACTER)
                  {
                     if(_loc7_ == 0)
                     {
                        _loc1_ = "." + _loc1_;
                        _loc5_ = false;
                     }
                     else if(--_loc7_ < 0)
                     {
                        _loc7_ = 0;
                     }
                  }
                  else if(_loc6_ == TreeListController.TAB_DECREASE_CHARACTER)
                  {
                     _loc7_++;
                  }
                  else if(!_loc5_)
                  {
                     _loc1_ = _loc6_ + _loc1_;
                     _loc5_ = true;
                  }
                  _loc8_--;
               }
            }
            else
            {
               addError("TreeListController failed to getCurrentTreePath: " + _loc3_ + " not found");
            }
         }
         return _loc1_;
      }
   }
}

