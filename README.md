# DictToModel
字典转model工具,也包含了一个model转json工具类
```
    let dict:[String:Any] = [...]
    let kvcModel = TestModel()
    //将字典转为model
    GHDictToModel.kvcModel(dict: dict, model: kvcModel)
    //
    print(kvcModel.toJSON())
```
# 使用本工具类的目的:
 1. 防止一些简单的赋值时因类型不统一而产生崩溃;
 2. 防止访问空值产生崩溃;
 3. 会列出model与接口不同的地方的日志,方便查错
 
 # 使用DictToModel将字典转成model的条件:
 1. model以及model中包含的子model都必须继承GHKVCModel类
 2. 目前有些基本类型的可选类型(已知的有Int?,Float?,Double?,Bool?等)属性,没法通过setValue的方式给属性赋值.建议使用这些数值的可选类型.
 3. 不能对常量赋值，不然会丢弃掉.
 
 # GHKVCModel类:
 1. 要使用GHDictToModel工具类,实现字典转model必须继承本类
 2. required override init()
    子类必须实现的构造方法
 3. func subModelTypes<T:GHKVCModel>()->[String:T.Type]
    在这里声明model中含有的子model类型,且此类型必须继承GHKVCModel.如果在这声明的属性类型和定义的类型不一质时，该属性将不作处理
 4. func modelPropDictKeyMap()->[String:String]
    model对应字典的映射表，当model中属性名和字典中key名不一样时设置对应关系
  
 # 具体的处理规则:
 1. 数值类型属性:
     - 不处理属性是Int8,Int16,Int64,Float16,Float64等类型的数值型数组，目前支持UInt,Int,Float,Double,NSNumber等类型的数值型数组
     - 如果属性为数值可选类型且不是(NSNumber?)时直接丢弃
     - 字典和model对应的key和属性同为数值型时，直接赋值;
     - 字典中key为字符串型时,如果能将字符串转为数值时，将转换的结果赋值给model属性;
     - 字典中key为布尔型时，true对应为数值1,false对应为0
     - 其它情况下不改变model属性的值
 2. 字符串类型属性:
     - 字典和model对应的key和属性同为字符串型时，直接赋值;
     - 字典中key为Bool类型时，true转为字符串"true",false转为字符串"false"
     - 字典中key为Number类型时，将数值转为字符串赋值
     - 其它情况下不改变model属性的值
 3. 处理Bool属性:
     - 属性是(Bool?)型会直接丢弃,不处理
     - 字典和model对应的key和属性同为Bool型时，直接赋值;
     - 字典中key值是数值类型时，将数值转化为Bool型，0是false,其它值为true
     - 字典中key值是字符串类型时，判断字符串如果在trueStrList中时为true,如果在falseStrList中时为false,其它情况丢弃;(trueStrList和falseStrList可根据自己的需要进行修改)
     - 其它情况下不改变model属性的值
 4. 处理Int型数组属性:
     - 字典对应的key值也只能是数值型数组，否则被丢弃
     - 浮点型数值会转化成整型
 5. 处理UInt型数组属性:
     1. 字典对应的key值也只能是数值型数组，否则被丢弃
     2. 浮点型数值会转化成UInt整型
 6. 处理float型数组属性:
     字典对应的key值也只能是数值型数组，否则被丢弃
 7. 处理double型数组属性:
     字典对应的key值也只能是数值型数组，否则被丢弃
 8. 处理NSNumber型数组属性:
     字典对应的key值也只能是数值型数组，否则被丢弃
 9. 如果属性是字典型数组[[String:Any]]，并且key也是字典型数组[[String:Any]]，直接赋值
 10. 处理对象类型Array属性:对象类型必须是GHKVCModel的子类
 11. 属性是字典类型:统一只处理[String:Any]型字典,其它类型字典直接丢弃
 12. 处理子model属性，对应的key值必须是[String:Any]类型，否则丢弃
