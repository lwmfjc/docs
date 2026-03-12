---
title: 100cpp映射容器
description: 100cpp映射容器
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-11T16:22:01+08:00
lastmod: 2026-03-11T16:22:01+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 简介

## 什么是 Map？

- Map 是一种容器，用于存储==键值对==。它允许你通过一个“键”（Key）来快速查找对应的“值”（Value）。
- 类比：就像一本字典，单词是键，定义是值。

## std::map vs std::unordered\_map

- std::map (==有序==映射)：
    - 底层结构：红黑树（一种自平衡二叉搜索树）。
    - 特点：元素按键的顺序自动排序。
    - 复杂度：==查找、插入、删除均为 O(logn)==。
- std::unordered\_map (无序映射)：    
    - 底层结构：哈希表（Hash Table）。
    - 特点：==元素没有特定顺序==。
    - 复杂度：==平均情况下查找速度为 O(1)==，通常比 `std::map` 快，除非哈希冲突严重。

## 代码演示：基础用法

- 展示如何定义 `std::map<std::string, CityRecord>`。
- 使用 `operator[]` 进行赋值：`map["Berlin"] = CityRecord { ... };`。
- 注意：如果访问一个不存在的键，`operator[]` 会自动创建一个默认构造的对象并插入。

## 迭代与访问

- 演示如何使用 `for (auto& [key, value] : map)`（C++17 结构化绑定）遍历 Map。
- 解释了老式迭代器用法：`it->first` 是键，`it->second` 是值。

## 性能取舍与选择建议

- 优先选择 `std::unordered_map`：如果你只需要快速查找，不需要元素有序，那么无序映射通常性能更优。
- 选择 `std::map` 的场景：当你需要遍历时保持特定顺序，或者需要使用类似 `lower_bound` 的区间查找功能时。

## 复杂键的处理

- 讲解了如果使用自定义类作为键，`std::map` 需要该类重载 `<` 运算符，而 `std::unordered_map` 则需要提供哈希函数。

```cpp
#ifdef LY_EP100

#include <iostream>  
#include <map>
#include <unordered_map>
#include <string>

struct CityRecord
{
	std::string Name;
	uint64_t Population;
	double Latitude, Longitude;

};

 std::ostream& operator<<(std::ostream& stream,
	const CityRecord& cityRecord)
{ 
	std::cout << "Name: " << cityRecord.Name << ","
		<< "Population: " << cityRecord.Population << ","
		<< "Latitude: " << cityRecord.Latitude << ","
		<< "Longitude: " << cityRecord.Longitude << std::endl;
	return stream;
}

namespace std {

	template<>
	struct hash<CityRecord>
	{
		size_t operator()(const CityRecord& key)
		{
			//hash<std::string>()这是调用构造函数，
			//然后构造了std::hash<CityRecord> 类型的对象，
			//之后调用了该对象的()重载方法
			return hash<std::string>()(key.Name);
		}
	};
}
int main()
{

	//计算City
	CityRecord cityRecord = { "name1",10000,2.3,4.5 };
	auto hashcode=std::hash<CityRecord>()(cityRecord);
	if (hashcode)
	{
		std::cout << "hashcode: " << hashcode << std::endl;
		std::cout << cityRecord << std::endl;
	}
	std::cin.get();
	return 0;
}

#endif
```

### 模板特化

#### 1\. 什么是普通模板？（工厂的模具）

模板就像一个==通用的模具==。比如你想写一个 `print` 函数，不管是 `int`、`float` 还是 `string` 都能用：

```cpp
template<typename T>
void print(T value) {
    std::cout << "通用打印: " << value << std::endl;
}
```

当你调用 `print(10)` 或 `print("Hello")` 时，编译器会根据这个模具自动生成对应的代码。

#### 2\. 什么是模板特化？（给特殊客人的定制版）

有时候，==通用的模具对某些特定类型不好使==。

比如，你想打印 `bool` 类型。通用的模具会打印 `1` 或 `0`。但你觉得这样不直观，你希望打印 `bool` 时输出 `"Yes"` 或 `"No"`。

这时候你就需要==特化==（Specialization）—— 告诉编译器：“如果是别的类型，按通用模具来；==如果是 `bool` 类型，请按我专门写的这套逻辑来。==”

```cpp
// 1. 通用模板 (Primary Template)
template<typename T>
struct Printer {
    void print(T value) { std::cout << value << std::endl; }
};

// 2. 全特化 (Full Specialization) —— 专门针对 bool 类型
template<> // 注意：这里尖括号空了，因为类型已经定死在下面了
struct Printer<bool> {
    void print(bool value) {
        std::cout << (value ? "Yes" : "No") << std::endl;
    }
};
```

